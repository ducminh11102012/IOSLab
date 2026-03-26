import { DeviceStatus } from "../../simulator/models/types";
import { DomainError } from "../../utils/errors";

const transitions: Record<DeviceStatus, DeviceStatus[]> = {
  created: ["booting", "stopped", "error"],
  booting: ["ready", "error"],
  ready: ["booting", "busy", "shutting_down", "error"],
  busy: ["ready", "shutting_down", "error"],
  shutting_down: ["stopped", "error"],
  stopped: ["booting", "error"],
  error: ["stopped", "booting"]
};

export function transitionDeviceState(from: DeviceStatus, to: DeviceStatus): DeviceStatus {
  if (!transitions[from]?.includes(to)) {
    throw new DomainError(`Invalid device transition: ${from} -> ${to}`, 409);
  }
  return to;
}
