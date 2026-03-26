import { FastifyInstance } from "fastify";
import { metricsRegistry } from "../../metrics/prometheus";
import { OrchestratorService } from "../../orchestrator/services/orchestratorService";

export async function registerMetricsRoutes(app: FastifyInstance, orchestrator: OrchestratorService): Promise<void> {
  app.get("/metrics", async (_request, reply) => {
    reply.header("content-type", metricsRegistry.contentType);
    return metricsRegistry.metrics();
  });

  app.get("/metrics/summary", async () => ({
    devices: orchestrator.listDevices().length,
    jobs: orchestrator.listJobs().length,
    queueDepth: orchestrator.queueDepth()
  }));
}
