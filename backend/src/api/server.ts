import Fastify from "fastify";
import { OrchestratorService } from "../orchestrator/services/orchestratorService";
import { registerHealthRoutes } from "./routes/health";
import { registerDeviceRoutes } from "./routes/devices";
import { registerTestRoutes } from "./routes/tests";
import { registerMetricsRoutes } from "./routes/metrics";
import { errorHandler } from "./middleware/errorHandler";
import { registerLogSocket } from "../websocket/registerLogSocket";

export function buildServer(orchestrator: OrchestratorService) {
  const app = Fastify({ logger: { level: process.env.LOG_LEVEL ?? "info" } });

  app.setErrorHandler(errorHandler);

  app.addHook("onRequest", async (request) => {
    request.log.info({ method: request.method, url: request.url }, "incoming_request");
  });

  app.addHook("onResponse", async (request, reply) => {
    request.log.info({ statusCode: reply.statusCode, url: request.url }, "request_completed");
  });

  void registerHealthRoutes(app);
  void registerDeviceRoutes(app, orchestrator);
  void registerTestRoutes(app, orchestrator);
  void registerMetricsRoutes(app, orchestrator);
  registerLogSocket(app);

  return app;
}
