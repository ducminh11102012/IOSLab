export class DomainError extends Error {
  constructor(message: string, public readonly statusCode = 400) {
    super(message);
    this.name = "DomainError";
  }
}
