import { emitEngineEvent } from "../../orchestrator/events/logEmitter";
import { runCommand } from "./commandRunner";

export interface XcodebuildRunParams {
  scheme: string;
  destination: string;
  projectPath?: string;
  workspacePath?: string;
  configuration?: string;
  resultBundlePath: string;
}

export class XcodebuildClient {
  async build(params: XcodebuildRunParams): Promise<{ output: string }> {
    return this.execute("build", params);
  }

  async runTests(params: XcodebuildRunParams): Promise<{ output: string }> {
    return this.execute("test", params);
  }

  private async execute(action: "build" | "test", params: XcodebuildRunParams): Promise<{ output: string }> {
    emitEngineEvent({ source: "xcodebuild", type: "started", action, message: `${action} started`, metadata: { scheme: params.scheme, destination: params.destination } });

    const pathArgs = params.workspacePath
      ? ["-workspace", params.workspacePath]
      : ["-project", params.projectPath ?? "ioslab.xcodeproj"];

    const args = [
      action,
      ...pathArgs,
      "-scheme",
      params.scheme,
      "-configuration",
      params.configuration ?? "Debug",
      "-destination",
      params.destination,
      "-resultBundlePath",
      params.resultBundlePath
    ];

    try {
      const { stdout, stderr, durationMs } = await runCommand("xcodebuild", args, {
        timeoutMs: 300_000,
        retries: 1,
        mockResult: { stdout: `${action}-ok`, stderr: "", code: 0, durationMs: 1 }
      });
      emitEngineEvent({ source: "xcodebuild", type: "log", action, message: stdout.slice(-4000), metadata: { stderr: stderr.slice(-4000), durationMs } });
      emitEngineEvent({ source: "xcodebuild", type: "finished", action, message: `${action} finished` });
      return { output: `${stdout}\n${stderr}` };
    } catch (error) {
      emitEngineEvent({ source: "xcodebuild", type: "error", action, message: `${action} failed`, metadata: { error: String(error) } });
      throw error;
    }
  }
}
