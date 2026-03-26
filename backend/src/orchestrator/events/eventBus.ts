type Handler<T> = (event: T) => void;

export class EventBus<T> {
  private handlers: Handler<T>[] = [];

  publish(event: T): void {
    this.handlers.forEach((h) => h(event));
  }

  subscribe(handler: Handler<T>): () => void {
    this.handlers.push(handler);
    return () => {
      this.handlers = this.handlers.filter((h) => h !== handler);
    };
  }
}
