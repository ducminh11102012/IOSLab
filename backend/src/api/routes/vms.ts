import { FastifyInstance } from "fastify";
import { z } from "zod";
import { OrchestratorService } from "../../orchestrator/services/orchestratorService";

const spawnVmSchema = z.object({
  name: z.string().min(2),
  runtime: z.string().min(2),
  cpu: z.number().int().min(1).max(32).optional(),
  memory: z.number().int().min(1).max(128).optional(),
  disk: z.number().int().min(1).max(1024).optional(),
});

const inputVmSchema = z.object({
  type: z.enum(["tap", "swipe", "keypress", "scroll"]),
  x: z.number().optional(),
  y: z.number().optional(),
  key: z.string().optional(),
  duration: z.number().optional(),
});

const backupVmSchema = z.object({
  name: z.string().min(1),
});

const restoreVmSchema = z.object({
  name: z.string().min(1),
});

const switchVmSchema = z.object({
  cpu: z.number().int().min(1).max(32).optional(),
  memory: z.number().int().min(1).max(128).optional(),
  disk: z.number().int().min(1).max(1024).optional(),
});

export async function registerVmRoutes(app: FastifyInstance, orchestrator: OrchestratorService): Promise<void> {
  // Get all VMs
  app.get("/vms", async () => {
    return { items: orchestrator.vmEngine.list() };
  });

  // Spawn VM
  app.post("/vms/spawn", async (request) => {
    const payload = spawnVmSchema.parse(request.body);
    // Spawns VM inside unified device pool & VM lifecycle manager
    const device = await orchestrator.spawnDevice({
      name: payload.name,
      runtime: payload.runtime,
      type: "vm",
      cpu: payload.cpu,
      memory: payload.memory,
      disk: payload.disk,
    });
    return device;
  });

  // Get Screenshot
  app.get<{ Params: { id: string } }>("/vms/:id/screenshot", async (request, reply) => {
    const screenshotInfo = orchestrator.vmEngine.getScreenshot(request.params.id);
    return screenshotInfo;
  });

  // Inject Input
  app.post<{ Params: { id: string } }>("/vms/:id/input", async (request) => {
    const payload = inputVmSchema.parse(request.body);
    const result = orchestrator.vmEngine.injectInput(request.params.id, payload);
    return result;
  });

  // Backup VM state
  app.post<{ Params: { id: string } }>("/vms/:id/backup", async (request) => {
    const payload = backupVmSchema.parse(request.body);
    const result = await orchestrator.vmEngine.backup(request.params.id, payload.name);
    return result;
  });

  // Restore VM backup
  app.post<{ Params: { id: string } }>("/vms/:id/restore", async (request) => {
    const payload = restoreVmSchema.parse(request.body);
    const result = await orchestrator.vmEngine.restoreBackup(request.params.id, payload.name);
    return result;
  });

  // Switch VM CPU/Memory/Disk Configuration
  app.post<{ Params: { id: string } }>("/vms/:id/switch", async (request) => {
    const payload = switchVmSchema.parse(request.body);
    const result = await orchestrator.vmEngine.switchConfig(request.params.id, payload);
    return result;
  });

  // AI exploratory test generation flow
  app.post<{ Params: { id: string } }>("/vms/:id/agent/explore", async (request) => {
    const result = orchestrator.vmEngine.proposeTestFlow(request.params.id);
    return result;
  });

  // Mobile Chaos Injection endpoint
  app.post<{ Params: { id: string } }>("/vms/:id/chaos", async (request) => {
    const chaosSchema = z.object({
      networkProfile: z.string().optional(),
      thermalThrottle: z.boolean().optional(),
      systemClockOffset: z.number().optional()
    });
    const payload = chaosSchema.parse(request.body);
    const result = orchestrator.vmEngine.injectChaos(request.params.id, payload);
    return result;
  });

  // Device Aging Simulation endpoint
  app.post<{ Params: { id: string } }>("/vms/:id/aging", async (request) => {
    const agingSchema = z.object({
      batteryDegraded: z.boolean().optional(),
      diskFullLevel: z.number().optional()
    });
    const payload = agingSchema.parse(request.body);
    const result = orchestrator.vmEngine.simulateAging(request.params.id, payload);
    return result;
  });

  // Retrieve Time-Travel Frames
  app.get<{ Params: { id: string } }>("/vms/:id/timetravel", async (request) => {
    const result = orchestrator.vmEngine.getTimeTravelFrames(request.params.id);
    return { items: result };
  });
}
