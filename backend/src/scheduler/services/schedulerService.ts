import { emitEngineEvent } from "../../orchestrator/events/logEmitter";
import { TestJob, Device } from "../../simulator/models/types";
import { getCapacitySnapshot } from "../policies/capacityPolicy";

export interface SchedulerResult {
  canRun: boolean;
  reason?: string;
  device?: Device;
}

export class SchedulerService {
  selectDevice(job: TestJob, devices: Device[]): SchedulerResult {
    const capacity = getCapacitySnapshot();
    const busyDevices = devices.filter((d) => d.status === "busy").length;
    if (busyDevices >= capacity.maxSimulators) {
      return { canRun: false, reason: "capacity_exceeded" };
    }

    const compatible = devices.find((device) => {
      if (device.status !== "ready") return false;
      const runtimeMatch = !job.requiredRuntime || device.runtime === job.requiredRuntime;
      const modelMatch = !job.requiredModelId || device.modelId === job.requiredModelId;
      return runtimeMatch && modelMatch;
    });

    if (!compatible) {
      return { canRun: false, reason: "no_compatible_device" };
    }

    emitEngineEvent({
      source: "scheduler",
      type: "started",
      action: "assign_job",
      message: `Assigned job ${job.id} to device ${compatible.id}`,
      metadata: { jobId: job.id, deviceId: compatible.id }
    });

    return { canRun: true, device: compatible };
  }

  backoffMs(retries: number): number {
    return Math.min(30_000, 500 * 2 ** retries);
  }
}
