import { FastifyInstance } from "fastify";
import { OrchestratorService } from "../../orchestrator/services/orchestratorService";
import { spawnDeviceSchema, transitionDeviceSchema } from "../schemas/devices";

export async function registerDeviceRoutes(app: FastifyInstance, orchestrator: OrchestratorService): Promise<void> {
  app.get("/devices", async () => ({ items: orchestrator.listDevices() }));

  app.post("/devices/spawn", async (request) => {
    const payload = spawnDeviceSchema.parse(request.body);
    return orchestrator.spawnDevice(payload);
  });

  app.post("/devices/boot", async (request) => {
    const payload = transitionDeviceSchema.parse(request.body);
    return orchestrator.transitionDevice(payload.id, payload.target);
  });

  app.post("/devices/shutdown", async (request) => {
    const payload = transitionDeviceSchema.parse(request.body);
    return orchestrator.transitionDevice(payload.id, payload.target);
  });
}
