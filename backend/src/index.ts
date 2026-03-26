import { env } from "./config/env";
import { buildServer } from "./api/server";
import { OrchestratorService } from "./orchestrator/services/orchestratorService";

async function start(): Promise<void> {
  const orchestrator = new OrchestratorService();
  const server = buildServer(orchestrator);

  try {
    await server.listen({ host: env.host, port: env.port });
    server.log.info(`iOSLab backend listening on ${env.host}:${env.port}`);
  } catch (error) {
    server.log.error(error);
    process.exit(1);
  }
}

void start();
