#!/usr/bin/env node
import { Command } from "commander";
import { ApiClient } from "./client/apiClient";
import { bootDevice, shutdownDevice, spawnDevice } from "./commands/deviceCommands";
import { runTest, showStatus, streamJobLogs } from "./commands/testCommands";

const program = new Command();
const client = new ApiClient();

program.name("ioslab").description("iOSLab CLI").version("0.1.0");

program.command("spawn").argument("<device>").action((device) => spawnDevice(client, device));
program.command("boot").argument("<deviceId>").action((deviceId) => bootDevice(client, deviceId));
program.command("shutdown").argument("<deviceId>").action((deviceId) => shutdownDevice(client, deviceId));

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
