export type EngineEventType = "started" | "log" | "finished" | "error";

export interface EngineEvent {
  source: "simctl" | "xcodebuild" | "scheduler" | "orchestrator";
  type: EngineEventType;
  action: string;
  message: string;
  timestamp: string;
  metadata?: Record<string, unknown>;
}
