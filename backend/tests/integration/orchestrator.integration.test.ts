import test from "node:test";
import assert from "node:assert/strict";
import { buildServer } from "../../src/api/server";
import { OrchestratorService } from "../../src/orchestrator/services/orchestratorService";

process.env.IOSLAB_SIMULATOR_MOCK = "true";

test("spawn simulator, run test, and fetch artifacts", async () => {
  const orchestrator = new OrchestratorService();
  const app = buildServer(orchestrator);

  const spawn = await app.inject({
    method: "POST",
    url: "/devices/spawn",
    payload: { name: "iPhone 15", runtime: "com.apple.CoreSimulator.SimRuntime.iOS-18-0", modelId: "com.apple.CoreSimulator.SimDeviceType.iPhone-15" }
  });

  assert.equal(spawn.statusCode, 200);

  const run = await app.inject({ method: "POST", url: "/tests/run", payload: { testTarget: "AppTests" } });
  assert.equal(run.statusCode, 200);

  const jobId = run.json().job.id as string;

  const artifacts = await app.inject({ method: "GET", url: `/tests/${jobId}/artifacts` });
  assert.equal(artifacts.statusCode, 200);
  assert.ok(Array.isArray(artifacts.json().items));

  await app.close();
});
