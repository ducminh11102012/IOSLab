import websocket from "@fastify/websocket";
import { FastifyInstance } from "fastify";
import { logStream } from "./logStream";

export function registerLogSocket(app: FastifyInstance): void {
  app.register(websocket);

  app.get("/ws/logs", { websocket: true }, (connection) => {
    const unsubscribe = logStream.subscribe((event) => {
      connection.socket.send(JSON.stringify(event));
    });

    connection.socket.on("close", () => {
      unsubscribe();
    });
  });
}
