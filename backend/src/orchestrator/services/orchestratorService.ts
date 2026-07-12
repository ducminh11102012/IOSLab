import { randomUUID } from "node:crypto";
import { setTimeout as delay } from "node:timers/promises";
import { PoolManager } from "../../simulator/pool/poolManager";
import { Device, DeviceStatus, TestJob, DeviceType } from "../../simulator/models/types";
import { transitionDeviceState } from "../state/deviceStateMachine";
import { transitionJobState } from "../state/jobStateMachine";
import { InMemoryQueue } from "../../scheduler/queue/inMemoryQueue";
import { getCapacitySnapshot, getActiveLoad, getDeviceCost } from "../../scheduler/policies/capacityPolicy";
import { activeDevicesGauge, executedJobsCounter, queuedJobsGauge } from "../../metrics/prometheus";
import { DomainError } from "../../utils/errors";
import { emitEngineEvent } from "../events/logEmitter";
import { SchedulerService } from "../../scheduler/services/schedulerService";
import { SimulatorEngine } from "../../simulator/engine/simulatorEngine";
import { VMEngine } from "../../simulator/engine/vmEngine";

export class OrchestratorService {
  private readonly pool = new PoolManager();
  private readonly jobs = new Map<string, TestJob>();
  private readonly queue = new InMemoryQueue<string>();
  public readonly vmEngine = new VMEngine();

  constructor(
    private readonly scheduler = new SchedulerService(),
    private readonly engine = new SimulatorEngine()
  ) {
    // Register the pre-patched VM as an available device inside the unified pool
    const now = new Date().toISOString();
    this.pool.put({
      id: "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      name: "iPhone VM (iOS 18)",
      runtime: "com.apple.CoreSimulator.SimRuntime.iOS-18-0",
      status: "ready",
      type: "vm",
      variant: "boot-only",
      currentPatchTier: "boot-only",
      backupList: ["Clean Install", "Post-Setup", "App-Preloaded"],
      cpu: 4,
      memory: 6,
      disk: 64,
      screen: "1170x2532",
      createdAt: now,
      updatedAt: now
    });
  }

  async spawnDevice(input: { name: string; runtime: string; modelId?: string; type?: DeviceType; cpu?: number; memory?: number; disk?: number }): Promise<Device> {
    const capacity = getCapacitySnapshot();
    const type = input.type ?? "simulator";
    const currentLoad = getActiveLoad(this.pool.list());
    const cost = type === "vm" ? 4 : 1;

    if (currentLoad + cost > capacity.maxSimulators) {
      throw new DomainError(`Capacity exceeded. maxSimulators=${capacity.maxSimulators}`, 429);
    }

    const now = new Date().toISOString();
    let simulatorUdid: string | undefined;
    let variant: string | undefined;
    let currentPatchTier: string | undefined;
    let backupList: string[] | undefined;
    let cpu: number | undefined;
    let memory: number | undefined;
    let disk: number | undefined;
    let screen: string | undefined;

    if (type === "vm") {
      const config = await this.vmEngine.create({
        name: input.name,
        runtime: input.runtime,
        cpu: input.cpu,
        memory: input.memory,
        disk: input.disk
      });
      variant = config.variant;
      currentPatchTier = config.currentPatchTier;
      backupList = config.backupList;
      cpu = config.cpu;
      memory = config.memory;
      disk = config.disk;
      screen = config.screen;
      // Immediately run the boot pipeline (prepare -> patch -> restore -> cfw_install -> boot)
      await this.vmEngine.bootPipeline(config.id);
    } else {
      const created = await this.engine.createAndBoot(input);
      simulatorUdid = created.udid;
    }

    const device: Device = {
      id: type === "vm" ? this.vmEngine.list()[this.vmEngine.list().length - 1].id : randomUUID(),
      name: input.name,
      runtime: input.runtime,
      modelId: input.modelId,
      simulatorUdid,
      status: "ready",
      type,
      variant,
      currentPatchTier,
      backupList,
      cpu,
      memory,
      disk,
      screen,
      createdAt: now,
      updatedAt: now
    };

    this.pool.put(device);
    activeDevicesGauge.set(this.pool.list().length);
    emitEngineEvent({ source: "orchestrator", type: "finished", action: "spawn_device", message: `Spawned ${device.type} ${device.id}`, metadata: { simulatorUdid, type } });
    return device;
  }

  async transitionDevice(id: string, target: DeviceStatus): Promise<Device> {
    const device = this.pool.get(id);
    if (!device) {
      throw new DomainError(`Device not found: ${id}`, 404);
    }

    let status = transitionDeviceState(device.status, target);

    if (device.type === "vm") {
      if (target === "booting") {
        await this.vmEngine.bootPipeline(device.id);
        status = "ready";
      }
      if (target === "shutting_down" || target === "stopped") {
        await this.vmEngine.shutdown(device.id);
        status = "stopped";
      }
    } else {
      if (!device.simulatorUdid) {
        throw new DomainError(`Device ${id} has no simulator UDID`, 400);
      }
      if (target === "booting") {
        await this.engine.boot(device.simulatorUdid);
        status = "ready";
      }
      if (target === "shutting_down" || target === "stopped") {
        await this.engine.shutdown(device.simulatorUdid);
        status = "stopped";
      }
    }

    const updated: Device = { ...device, status, updatedAt: new Date().toISOString() };
    this.pool.update(updated);
    return updated;
  }

  listDevices(): Device[] {
    return this.pool.list();
  }

  enqueueTest(input: { testTarget: string; maxRetries?: number; requiredRuntime?: string; requiredModelId?: string }): TestJob {
    const now = new Date().toISOString();
    const job: TestJob = {
      id: randomUUID(),
      testTarget: input.testTarget,
      retries: 0,
      maxRetries: input.maxRetries ?? 1,
      requiredRuntime: input.requiredRuntime,
      requiredModelId: input.requiredModelId,
      status: "queued",
      createdAt: now,
      updatedAt: now
    };

    this.jobs.set(job.id, job);
    this.queue.enqueue(job.id);
    queuedJobsGauge.set(this.queue.size());
    emitEngineEvent({ source: "scheduler", type: "log", action: "enqueue_job", message: `Job queued: ${job.id}` });
    return job;
  }

  async scheduleNext(): Promise<TestJob | null> {
    const jobId = this.queue.dequeue();
    queuedJobsGauge.set(this.queue.size());
    if (!jobId) return null;

    const job = this.jobs.get(jobId);
    if (!job) return null;

    const decision = this.scheduler.selectDevice(job, this.pool.list());
    if (!decision.canRun || !decision.device) {
      this.queue.enqueue(jobId);
      queuedJobsGauge.set(this.queue.size());
      emitEngineEvent({ source: "scheduler", type: "log", action: "reschedule_job", message: `Job ${job.id} delayed`, metadata: { reason: decision.reason } });
      return null;
    }

    const scheduledStatus = transitionJobState(job.status, "scheduled");
    const runningStatus = transitionJobState(scheduledStatus, "running");
    const deviceBusy = transitionDeviceState(decision.device.status, "busy");

    this.pool.update({ ...decision.device, status: deviceBusy, updatedAt: new Date().toISOString() });

    const updated: TestJob = {
      ...job,
      status: runningStatus,
      assignedDeviceId: decision.device.id,
      updatedAt: new Date().toISOString()
    };

    this.jobs.set(updated.id, updated);
    executedJobsCounter.inc();

    emitEngineEvent({ source: "scheduler", type: "started", action: "run_job", message: `Running job ${updated.id}` });

    try {
      if (decision.device.type === "vm") {
        emitEngineEvent({ source: "orchestrator", type: "started", action: "run_job_vm", message: `Running VM test target ${updated.testTarget} on VM ${decision.device.id}...` });
        await delay(200); // simulate running test on VM
        this.completeJob(updated.id, true);
        this.pool.update({ ...decision.device, status: "ready", updatedAt: new Date().toISOString() });
        emitEngineEvent({ source: "scheduler", type: "finished", action: "run_job", message: `Job completed on VM ${updated.id}` });
      } else {
        const destination = `platform=iOS Simulator,id=${decision.device.simulatorUdid}`;
        await this.engine.runTest(updated.id, { scheme: updated.testTarget, destination, projectPath: "ioslab.xcodeproj" });
        this.completeJob(updated.id, true);
        this.pool.update({ ...decision.device, status: "ready", updatedAt: new Date().toISOString() });
        emitEngineEvent({ source: "scheduler", type: "finished", action: "run_job", message: `Job completed ${updated.id}` });
      }
    } catch (error) {
      await this.completeJob(updated.id, false);
      this.pool.update({ ...decision.device, status: "ready", updatedAt: new Date().toISOString() });
      emitEngineEvent({ source: "scheduler", type: "error", action: "run_job", message: `Job failed ${updated.id}`, metadata: { error: String(error) } });
    }

    return this.jobs.get(updated.id) ?? updated;
  }

  async completeJob(jobId: string, success: boolean): Promise<TestJob> {
    const job = this.jobs.get(jobId);
    if (!job) {
      throw new DomainError(`Job not found: ${jobId}`, 404);
    }

    let nextStatus: "completed" | "failed" | "retrying" = success ? "completed" : "failed";
    if (!success && job.retries < job.maxRetries) {
      nextStatus = "retrying";
    }

    const transitioned = transitionJobState(job.status, nextStatus);
    const updated: TestJob = {
      ...job,
      status: transitioned,
      retries: !success ? job.retries + 1 : job.retries,
      updatedAt: new Date().toISOString()
    };

    if (updated.status === "retrying") {
      const backoff = this.scheduler.backoffMs(updated.retries);
      emitEngineEvent({ source: "scheduler", type: "log", action: "retry_backoff", message: `Job ${updated.id} backoff ${backoff}ms` });
      await delay(backoff);
      updated.status = transitionJobState(updated.status, "queued");
      this.queue.enqueue(updated.id);
      queuedJobsGauge.set(this.queue.size());
    }

    this.jobs.set(updated.id, updated);
    return updated;
  }

  getJob(id: string): TestJob | undefined {
    return this.jobs.get(id);
  }

  listJobs(): TestJob[] {
    return [...this.jobs.values()];
  }

  queueDepth(): number {
    return this.queue.size();
  }

  listArtifacts(jobId: string) {
    return this.engine.listArtifacts(jobId);
  }
}
