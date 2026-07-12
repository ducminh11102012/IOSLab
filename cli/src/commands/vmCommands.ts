import ora from "ora";
import { ApiClient } from "../client/apiClient";
import { out } from "../utils/output";

export async function vmNew(
  client: ApiClient,
  name: string,
  options: { runtime?: string; cpu?: string; memory?: string; disk?: string }
): Promise<void> {
  const spinner = ora(`Creating VM "${name}"`).start();
  try {
    const runtime = options.runtime ?? "com.apple.CoreSimulator.SimRuntime.iOS-18-0";
    const payload = {
      name,
      runtime,
      cpu: options.cpu ? parseInt(options.cpu, 10) : 4,
      memory: options.memory ? parseInt(options.memory, 10) : 6,
      disk: options.disk ? parseInt(options.disk, 10) : 64,
    };
    const response = await client.post("/vms/spawn", payload);
    spinner.succeed("VM created successfully");
    out.json(response);
  } catch (error) {
    spinner.fail("VM creation failed");
    out.error(String(error));
  }
}

export async function vmBoot(client: ApiClient, id: string): Promise<void> {
  const spinner = ora(`Booting VM "${id}"`).start();
  try {
    const response = await client.post("/devices/boot", { id, target: "booting" });
    spinner.succeed("VM boot pipeline completed successfully");
    out.json(response);
  } catch (error) {
    spinner.fail("VM boot failed");
    out.error(String(error));
  }
}

export async function vmBackup(client: ApiClient, id: string, backupName: string): Promise<void> {
  const spinner = ora(`Creating state backup "${backupName}" for VM "${id}"`).start();
  try {
    const response = await client.post(`/vms/${id}/backup`, { name: backupName });
    spinner.succeed("VM state backup created successfully");
    out.json(response);
  } catch (error) {
    spinner.fail("VM state backup failed");
    out.error(String(error));
  }
}

export async function vmRestore(client: ApiClient, id: string, backupName: string): Promise<void> {
  const spinner = ora(`Restoring VM "${id}" to state backup "${backupName}"`).start();
  try {
    const response = await client.post(`/vms/${id}/restore`, { name: backupName });
    spinner.succeed("VM state backup restored successfully");
    out.json(response);
  } catch (error) {
    spinner.fail("VM state restore failed");
    out.error(String(error));
  }
}

export async function vmSwitch(
  client: ApiClient,
  id: string,
  options: { cpu?: string; memory?: string; disk?: string }
): Promise<void> {
  const spinner = ora(`Switching configuration for VM "${id}"`).start();
  try {
    const payload: Record<string, number> = {};
    if (options.cpu) payload.cpu = parseInt(options.cpu, 10);
    if (options.memory) payload.memory = parseInt(options.memory, 10);
    if (options.disk) payload.disk = parseInt(options.disk, 10);

    const response = await client.post(`/vms/${id}/switch`, payload);
    spinner.succeed("VM configuration switched successfully");
    out.json(response);
  } catch (error) {
    spinner.fail("VM config switch failed");
    out.error(String(error));
  }
}

export async function vmList(client: ApiClient): Promise<void> {
  const spinner = ora("Fetching virtualized iOS VMs").start();
  try {
    const response = await client.get("/vms");
    spinner.succeed("Fetched virtualized iOS VMs");
    out.json(response);
  } catch (error) {
    spinner.fail("Failed to fetch VMs");
    out.error(String(error));
  }
}
