import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export interface CommandResult {
  stdout: string;
  stderr: string;
  code: number;
  durationMs: number;
}

export interface CommandOptions {
  timeoutMs?: number;
  retries?: number;
  retryDelayMs?: number;
  mockResult?: CommandResult;
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export async function runCommand(command: string, args: string[], options: CommandOptions = {}): Promise<CommandResult> {
  if (process.env.IOSLAB_SIMULATOR_MOCK === "true") {
    return (
      options.mockResult ?? {
        stdout: "mock-ok",
        stderr: "",
        code: 0,
        durationMs: 0
      }
    );
  }

  const timeoutMs = options.timeoutMs ?? 120_000;
  const retries = options.retries ?? 0;
  const retryDelayMs = options.retryDelayMs ?? 500;

  let lastError: unknown;

  for (let attempt = 0; attempt <= retries; attempt += 1) {
    const started = Date.now();
    try {
      const result = await execFileAsync(command, args, { timeout: timeoutMs });
      return {
        stdout: result.stdout,
        stderr: result.stderr,
        code: 0,
        durationMs: Date.now() - started
      };
    } catch (error) {
      lastError = error;
      if (attempt < retries) {
        await sleep(retryDelayMs * (attempt + 1));
      }
    }
  }

  throw lastError;
}
