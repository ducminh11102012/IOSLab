#!/usr/bin/env node
import { Command } from "commander";
import { ApiClient } from "./client/apiClient";
import { bootDevice, shutdownDevice, spawnDevice } from "./commands/deviceCommands";
import { runTest, showStatus, streamJobLogs } from "./commands/testCommands";
import { vmNew, vmBoot, vmBackup, vmRestore, vmSwitch, vmList } from "./commands/vmCommands";

const program = new Command();
const client = new ApiClient();

program.name("ioslab").description("iOSLab CLI").version("0.1.0");

program
  .command("spawn")
  .argument("<device>")
  .option("--vm", "Spawn a virtualized real-iOS VM instead of a simulator")
  .action((device, options) => spawnDevice(client, device, options));

program.command("boot").argument("<deviceId>").action((deviceId) => bootDevice(client, deviceId));
program.command("shutdown").argument("<deviceId>").action((deviceId) => shutdownDevice(client, deviceId));

const vmCommand = program.command("vm").description("Manage virtualized real-iOS VM configurations and pipelines");

vmCommand
  .command("new")
  .argument("<name>")
  .option("--runtime <runtime>", "iOS version runtime")
  .option("--cpu <cpu>", "Number of vCPUs")
  .option("--memory <memory>", "RAM in GB")
  .option("--disk <disk>", "Disk size in GB")
  .action((name, options) => vmNew(client, name, options));

vmCommand
  .command("boot")
  .argument("<id>")
  .action((id) => vmBoot(client, id));

vmCommand
  .command("backup")
  .argument("<id>")
  .argument("<backupName>")
  .action((id, backupName) => vmBackup(client, id, backupName));

vmCommand
  .command("restore")
  .argument("<id>")
  .argument("<backupName>")
  .action((id, backupName) => vmRestore(client, id, backupName));

vmCommand
  .command("switch")
  .argument("<id>")
  .option("--cpu <cpu>", "Number of vCPUs")
  .option("--memory <memory>", "RAM in GB")
  .option("--disk <disk>", "Disk size in GB")
  .action((id, options) => vmSwitch(client, id, options));

vmCommand
  .command("list")
  .action(() => vmList(client));

program
  .command("test")
  .command("run")
  .argument("<target>")
  .action((target) => runTest(client, target));

program.command("status").action(() => showStatus(client));
program.command("logs").argument("<jobId>").action((jobId) => streamJobLogs(client, jobId));

program.parseAsync().catch((error) => {
  console.error(error);
  process.exit(1);
});
