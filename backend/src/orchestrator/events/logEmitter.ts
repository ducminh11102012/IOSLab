import { EventBus } from "./eventBus";
import { EngineEvent } from "./types";

export const engineEventBus = new EventBus<EngineEvent>();
const history: EngineEvent[] = [];

export function emitEngineEvent(event: Omit<EngineEvent, "timestamp">): void {
  const payload: EngineEvent = { ...event, timestamp: new Date().toISOString() };
  history.push(payload);
  if (history.length > 1000) {
    history.shift();
  }
  engineEventBus.publish(payload);
}

export function getEngineEventHistory(): EngineEvent[] {
  return [...history];
}
