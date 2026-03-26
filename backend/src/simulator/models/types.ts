export type DeviceStatus =
  | "created"
  | "booting"
  | "ready"
  | "busy"
  | "shutting_down"
  | "stopped"
  | "error";

export interface Runtime {
  id: string;
  name: string;
  version: string;
  isAvailable: boolean;
}

export interface DeviceModel {
  id: string;
  name: string;
  family: "iPhone" | "iPad";
}

export interface SimulatorDevice {
  udid: string;
  name: string;
  state: string;
  runtime: string;
  isAvailable: boolean;
  deviceTypeIdentifier?: string;
}

export interface Device {
  id: string;
  name: string;
  runtime: string;
  status: DeviceStatus;
  simulatorUdid?: string;
  modelId?: string;
  createdAt: string;
  updatedAt: string;
}

export type JobStatus = "queued" | "scheduled" | "running" | "retrying" | "completed" | "failed";

export interface TestJob {
  id: string;
  testTarget: string;
  retries: number;
  maxRetries: number;
  status: JobStatus;
  assignedDeviceId?: string;
  requiredRuntime?: string;
  requiredModelId?: string;
  shardIndex?: number;
  totalShards?: number;
  createdAt: string;
  updatedAt: string;
}
