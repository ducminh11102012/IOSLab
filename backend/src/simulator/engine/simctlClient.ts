import { emitEngineEvent } from "../../orchestrator/events/logEmitter";
import { SimulatorDevice } from "../models/types";
import { runCommand } from "./commandRunner";

export class SimctlClient {
  async create(name: string, runtime: string, deviceType = "com.apple.CoreSimulator.SimDeviceType.iPhone-15"): Promise<{ udid: string }> {
    emitEngineEvent({ source: "simctl", type: "started", action: "create", message: `Creating simulator ${name}`, metadata: { name, runtime, deviceType } });
    try {
      const { stdout, stderr, durationMs } = await runCommand("xcrun", ["simctl", "create", name, deviceType, runtime], {
        retries: 2,
        timeoutMs: 30_000,
        mockResult: { stdout: `mock-${name.toLowerCase().replace(/\s+/g, "-")}`, stderr: "", code: 0, durationMs: 1 }
      });
      emitEngineEvent({ source: "simctl", type: "log", action: "create", message: stdout.trim(), metadata: { stderr, durationMs } });
      emitEngineEvent({ source: "simctl", type: "finished", action: "create", message: "Simulator created" });
      return { udid: stdout.trim() };
    } catch (error) {
      emitEngineEvent({ source: "simctl", type: "error", action: "create", message: "Failed to create simulator", metadata: { error: String(error) } });
      throw error;
    }
  }

  async boot(udid: string): Promise<void> {
    await this.simpleAction("boot", ["simctl", "boot", udid], udid);
  }

  async shutdown(udid: string): Promise<void> {
    await this.simpleAction("shutdown", ["simctl", "shutdown", udid], udid);
  }

  async erase(udid: string): Promise<void> {
    await this.simpleAction("erase", ["simctl", "erase", udid], udid);
  }

  async list(): Promise<SimulatorDevice[]> {
    emitEngineEvent({ source: "simctl", type: "started", action: "list", message: "Listing simulators" });
    const { stdout } = await runCommand("xcrun", ["simctl", "list", "devices", "--json"], {
      retries: 1,
      timeoutMs: 20_000,
      mockResult: {
        stdout: JSON.stringify({ devices: { "com.apple.CoreSimulator.SimRuntime.iOS-18-0": [{ udid: "mock-1", name: "iPhone 15", state: "Shutdown", isAvailable: true }] } }),
        stderr: "",
        code: 0,
        durationMs: 1
      }
    });

    const parsed = JSON.parse(stdout) as { devices: Record<string, Array<{ udid: string; name: string; state: string; isAvailable: boolean; deviceTypeIdentifier?: string }>> };
    const mapped: SimulatorDevice[] = [];

    Object.entries(parsed.devices).forEach(([runtime, devices]) => {
      devices.forEach((device) => {
        mapped.push({ ...device, runtime });
      });
    });

    emitEngineEvent({ source: "simctl", type: "finished", action: "list", message: `Found ${mapped.length} simulators` });
    return mapped;
  }

  private async simpleAction(action: string, args: string[], udid: string): Promise<void> {
    emitEngineEvent({ source: "simctl", type: "started", action, message: `${action} ${udid}` });
    try {
      const { stdout, stderr, durationMs } = await runCommand("xcrun", args, {
        retries: 2,
        timeoutMs: 30_000,
        mockResult: { stdout: "ok", stderr: "", code: 0, durationMs: 1 }
      });
      emitEngineEvent({ source: "simctl", type: "log", action, message: stdout.trim() || "ok", metadata: { stderr, durationMs, udid } });
      emitEngineEvent({ source: "simctl", type: "finished", action, message: `${action} completed`, metadata: { udid } });
    } catch (error) {
      emitEngineEvent({ source: "simctl", type: "error", action, message: `${action} failed`, metadata: { udid, error: String(error) } });
      throw error;
    }
  }
}
