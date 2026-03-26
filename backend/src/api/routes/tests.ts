import { FastifyInstance } from "fastify";
import { OrchestratorService } from "../../orchestrator/services/orchestratorService";
import { runTestSchema } from "../schemas/tests";
import { getEngineEventHistory } from "../../orchestrator/events/logEmitter";

export async function registerTestRoutes(app: FastifyInstance, orchestrator: OrchestratorService): Promise<void> {
  app.get("/tests", async () => ({ items: orchestrator.listJobs() }));

  app.post("/tests/run", async (request) => {
    const payload = runTestSchema.parse(request.body);
    const job = orchestrator.enqueueTest(payload);
    const scheduled = await orchestrator.scheduleNext();
    return { job, scheduled };
  });

  app.get<{ Params: { id: string } }>("/tests/:id", async (request, reply) => {
    const job = orchestrator.getJob(request.params.id);
    if (!job) {
      reply.code(404);
      return { message: "Job not found" };
    }
    return job;
  });

  app.get<{ Params: { id: string } }>("/tests/:id/artifacts", async (request) => ({
    items: orchestrator.listArtifacts(request.params.id)
  }));
  app.get<{ Params: { id: string } }>("/tests/:id/logs", async (request) => ({
    items: getEngineEventHistory().filter((event) => JSON.stringify(event.metadata ?? {}).includes(request.params.id) || event.message.includes(request.params.id))
  }));
}
