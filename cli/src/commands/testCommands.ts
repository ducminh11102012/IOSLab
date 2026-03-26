import ora from "ora";
import { ApiClient } from "../client/apiClient";
import { out } from "../utils/output";

export async function runTest(client: ApiClient, target: string): Promise<void> {
  const spinner = ora(`Running test target ${target}`).start();
  try {
    const response = await client.post("/tests/run", { testTarget: target });
    spinner.succeed("Test submitted");
    out.json(response);
  } catch (error) {
    spinner.fail("Test submission failed");
    out.error(String(error));
  }
}

export async function showStatus(client: ApiClient): Promise<void> {
  const [devices, tests, metrics] = await Promise.all([
    client.get("/devices"),
    client.get("/tests"),
    client.get("/metrics/summary")
  ]);

  out.info("Devices");
  out.json(devices);
  out.info("Jobs");
  out.json(tests);
  out.info("Metrics");
  out.json(metrics);
}

export async function streamJobLogs(client: ApiClient, jobId: string): Promise<void> {
  out.info(`Streaming logs for job ${jobId}... Ctrl+C to stop.`);

  await new Promise<void>((resolve, reject) => {
    const socket = client.streamLogs(
      (payload) => {
        const text = JSON.stringify(payload);
        if (text.includes(jobId) || !jobId) {
          out.info(text);
        }
      },
      reject
    );

    process.on("SIGINT", () => {
      socket.close();
      resolve();
    });

    socket.on("close", () => resolve());
  });
}
