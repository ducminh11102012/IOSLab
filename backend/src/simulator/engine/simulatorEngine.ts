import path from "node:path";
import { randomUUID } from "node:crypto";
import { ArtifactService } from "../../artifacts/artifactService";
import { emitEngineEvent } from "../../orchestrator/events/logEmitter";
import { SimctlClient } from "./simctlClient";
import { XcodebuildClient, XcodebuildRunParams } from "./xcodebuildClient";

export class SimulatorEngine {
  constructor(
    private readonly simctl = new SimctlClient(),
    private readonly xcodebuild = new XcodebuildClient(),
    private readonly artifacts = new ArtifactService()
  ) {}

  async createAndBoot(input: { name: string; runtime: string; modelId?: string }): Promise<{ udid: string }> {
    const created = await this.simctl.create(input.name, input.runtime, input.modelId);
    await this.simctl.boot(created.udid);
    return created;
  }


  async boot(udid: string): Promise<void> {
    await this.simctl.boot(udid);
  }

  async shutdown(udid: string): Promise<void> {
    await this.simctl.shutdown(udid);
  }

  async shutdownAndErase(udid: string): Promise<void> {
    await this.simctl.shutdown(udid);
    await this.simctl.erase(udid);
  }

  async listDevices() {
    return this.simctl.list();
  }

  async runTest(jobId: string, params: Omit<XcodebuildRunParams, "resultBundlePath">): Promise<{ output: string; resultBundlePath: string }> {
    const resultBundlePath = path.resolve(process.cwd(), "artifacts-data", `${jobId}.xcresult`);
    const result = await this.xcodebuild.runTests({ ...params, resultBundlePath });

    await this.artifacts.add({
      id: randomUUID(),
      jobId,
      path: resultBundlePath,
      type: "xcresult",
      content: result.output
    });

    emitEngineEvent({ source: "orchestrator", type: "finished", action: "artifact.persist", message: "Stored xcresult artifact", metadata: { jobId, resultBundlePath } });
    return { output: result.output, resultBundlePath };
  }

  listArtifacts(jobId: string) {
    return this.artifacts.listForJob(jobId);
  }
}
