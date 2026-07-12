import os from "node:os";
import { Device } from "../../simulator/models/types";

export interface CapacitySnapshot {
  maxSimulators: number;
  cpuCores: number;
  memoryGb: number;
}

export const COST_WEIGHTS = {
  simulator: 1,
  vm: 4,
};

export function getCapacitySnapshot(): CapacitySnapshot {
  const cpuCores = os.cpus().length;
  const memoryGb = Math.round((os.totalmem() / (1024 ** 3)) * 10) / 10;
  const maxSimulators = Math.max(1, Math.floor(Math.min(cpuCores, memoryGb / 2)));

  return { maxSimulators, cpuCores, memoryGb };
}

export function getDeviceCost(device: Device): number {
  return device.type === "vm" ? COST_WEIGHTS.vm : COST_WEIGHTS.simulator;
}

export function getActiveLoad(devices: Device[]): number {
  return devices
    .filter((d) => ["busy", "booting", "preparing", "patching", "restoring", "installing"].includes(d.status))
    .reduce((sum, d) => sum + getDeviceCost(d), 0);
}
