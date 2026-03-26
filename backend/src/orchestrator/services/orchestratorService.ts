import { randomUUID } from "node:crypto";
import { setTimeout as delay } from "node:timers/promises";
import { PoolManager } from "../../simulator/pool/poolManager";
import { Device, DeviceStatus, TestJob } from "../../simulator/models/types";
import { transitionDeviceState } from "../state/deviceStateMachine";
import { transitionJobState } from "../state/jobStateMachine";
import { InMemoryQueue } from "../../scheduler/queue/inMemoryQueue";
import { getCapacitySnapshot } from "../../scheduler/policies/capacityPolicy";
import { activeDevicesGauge, executedJobsCounter, queuedJobsGauge } from "../../metrics/prometheus";
import { DomainError } from "../../utils/errors";
import { emitEngineEvent } from "../events/logEmitter";
import { SchedulerService } from "../../scheduler/services/schedulerService";
import { SimulatorEngine } from "../../simulator/engine/simulatorEngine";

export class OrchestratorService {
  private readonly pool = new PoolManager();
  private readonly jobs = new Map<string, TestJob>();
  private readonly queue = new InMemoryQueue<string>();

  constructor(
    private readonly scheduler = new SchedulerService(),
    private readonly engine = new SimulatorEngine()
  ) {}

  async spawnDevice(input: { name: string; runtime: string; modelId?: string }): Promise<Device> {
    const capacity = getCapacitySnapshot();
    if (this.pool.list().length >= capacity.maxSimulators) {
      throw new DomainError(`Capacity exceeded. maxSimulators=${capacity.maxSimulators}`, 429);
    }

    const now = new Date().toISOString();
    const created = await this.engine.createAndBoot(input);
    const device: Device = {
      id: randomUUID(),
      name: input.name,
      runtime: input.runtime,
      modelId: input.modelId,
      simulatorUdid: created.udid,
      status: "ready",
      createdAt: now,
      updatedAt: now
    };

    this.pool.put(device);
    activeDevicesGauge.set(this.pool.list().length);
    emitEngineEvent({ source: "orchestrator", type: "finished", action: "spawn_device", message: `Spawned ${device.id}`, metadata: { simulatorUdid: created.udid } });
    return device;
  }

  async transitionDevice(id: string, target: DeviceStatus): Promise<Device> {
    const device = this.pool.get(id);
    if (!device) {
      throw new DomainError(`Device not found: ${id}`, 404);
    }

    if (!device.simulatorUdid) {
      throw new DomainError(`Device ${id} has no simulator UDID`, 400);
    }

    let status = transitionDeviceState(device.status, target);

    if (target === "booting") {
      await this.engine.boot(device.simulatorUdid);
      status = "ready";
    }

    if (target === "shutting_down" || target === "stopped") {
      await this.engine.shutdown(device.simulatorUdid);
      status = "stopped";
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
      const destination = `platform=iOS Simulator,id=${decision.device.simulatorUdid}`;
      await this.engine.runTest(updated.id, { scheme: updated.testTarget, destination, projectPath: "ioslab.xcodeproj" });
      this.completeJob(updated.id, true);
      this.pool.update({ ...decision.device, status: "ready", updatedAt: new Date().toISOString() });
      emitEngineEvent({ source: "scheduler", type: "finished", action: "run_job", message: `Job completed ${updated.id}` });
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
