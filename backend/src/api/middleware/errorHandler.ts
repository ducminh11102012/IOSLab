import { FastifyError, FastifyReply, FastifyRequest } from "fastify";
import { ZodError } from "zod";
import { DomainError } from "../../utils/errors";

export function errorHandler(error: FastifyError | Error, _request: FastifyRequest, reply: FastifyReply): void {
  if (error instanceof ZodError) {
    reply.code(400).send({ message: "Validation error", issues: error.issues });
    return;
  }

  if (error instanceof DomainError) {
    reply.code(error.statusCode).send({ message: error.message });
    return;
  }

  reply.code(500).send({ message: error.message || "Internal server error" });
}
