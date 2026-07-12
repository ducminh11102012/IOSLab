import { FastifyInstance } from "fastify";
import { OrchestratorService } from "../../orchestrator/services/orchestratorService";
import { McpServer, McpRequest } from "../../mcp/mcpServer";

export async function registerMcpRoutes(app: FastifyInstance, orchestrator: OrchestratorService): Promise<void> {
  const mcpServer = new McpServer(orchestrator);

  app.post("/mcp", async (request, reply) => {
    const mcpReq = request.body as McpRequest;
    if (!mcpReq || typeof mcpReq.method !== "string") {
      reply.code(400);
      return { error: "Invalid MCP Request. Must be a valid JSON-RPC 2.0 request." };
    }
    const response = await mcpServer.handleRequest(mcpReq);
    return response;
  });
}
