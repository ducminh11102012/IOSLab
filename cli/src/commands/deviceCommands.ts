import ora from "ora";
import { ApiClient } from "../client/apiClient";
import { out } from "../utils/output";

export async function spawnDevice(client: ApiClient, device: string): Promise<void> {
  const spinner = ora(`Spawning ${device}`).start();
  try {
    const response = await client.post("/devices/spawn", {
      name: device,
      runtime: "com.apple.CoreSimulator.SimRuntime.iOS-18-0",
      modelId: "com.apple.CoreSimulator.SimDeviceType.iPhone-15"
    });
    spinner.succeed("Simulator spawned");
    out.json(response);
  } catch (error) {
    spinner.fail("Spawn failed");
    out.error(String(error));
  }
}

export async function bootDevice(client: ApiClient, id: string): Promise<void> {
  const spinner = ora(`Booting ${id}`).start();
  try {
    const response = await client.post("/devices/boot", { id, target: "booting" });
    spinner.succeed("Device boot transition requested");
    out.json(response);
  } catch (error) {
    spinner.fail("Boot failed");
    out.error(String(error));
  }
}

export async function shutdownDevice(client: ApiClient, id: string): Promise<void> {
  const spinner = ora(`Shutting down ${id}`).start();
  try {
    const response = await client.post("/devices/shutdown", { id, target: "shutting_down" });
    spinner.succeed("Shutdown transition requested");
    out.json(response);
  } catch (error) {
    spinner.fail("Shutdown failed");
    out.error(String(error));
  }
}
