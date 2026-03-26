import os from "node:os";

export interface CapacitySnapshot {
  maxSimulators: number;
  cpuCores: number;
  memoryGb: number;
}

export function getCapacitySnapshot(): CapacitySnapshot {
  const cpuCores = os.cpus().length;
  const memoryGb = Math.round((os.totalmem() / (1024 ** 3)) * 10) / 10;
  const maxSimulators = Math.max(1, Math.floor(Math.min(cpuCores, memoryGb / 2)));

  return { maxSimulators, cpuCores, memoryGb };
}
