import test from "node:test";
import assert from "node:assert/strict";
import { spawnDevice, shutdownDevice } from "../src/commands/deviceCommands";
import { runTest, showStatus } from "../src/commands/testCommands";
import { ApiClient } from "../src/client/apiClient";
import { buildServer } from "../../backend/src/api/server";
import { OrchestratorService } from "../../backend/src/orchestrator/services/orchestratorService";

process.env.IOSLAB_SIMULATOR_MOCK = "true";

test("cli commands hit backend endpoints", async () => {
  const orchestrator = new OrchestratorService();
  const server = buildServer(orchestrator);
  await server.listen({ port: 4100, host: "127.0.0.1" });

  const client = new ApiClient({ baseUrl: "http://127.0.0.1:4100", wsUrl: "ws://127.0.0.1:4100/ws/logs" });

  await spawnDevice(client, "iPhone 15");
  const devices = (await client.get<{ items: Array<{ id: string }> }>("/devices")).items;
  assert.ok(devices.length > 0);

  await runTest(client, "AppTests");
  const jobs = (await client.get<{ items: Array<{ id: string }> }>("/tests")).items;
  assert.ok(jobs.length > 0);

  await showStatus(client);
  await shutdownDevice(client, devices[0].id);

  await server.close();
});
