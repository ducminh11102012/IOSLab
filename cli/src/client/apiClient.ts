import WebSocket from "ws";

export interface ApiClientOptions {
  baseUrl?: string;
  wsUrl?: string;
}

export class ApiClient {
  readonly baseUrl: string;
  readonly wsUrl: string;

  constructor(options: ApiClientOptions = {}) {
    this.baseUrl = options.baseUrl ?? process.env.IOSLAB_API_URL ?? "http://127.0.0.1:4000";
    this.wsUrl = options.wsUrl ?? process.env.IOSLAB_WS_URL ?? "ws://127.0.0.1:4000/ws/logs";
  }

  async get<T>(path: string): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`);
    if (!response.ok) {
      throw new Error(`${response.status} ${response.statusText}`);
    }
    return (await response.json()) as T;
  }

  async post<T>(path: string, body: unknown): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body)
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(text || `${response.status} ${response.statusText}`);
    }

    return (await response.json()) as T;
  }

  streamLogs(handler: (payload: Record<string, unknown>) => void, onError: (error: Error) => void): WebSocket {
    const socket = new WebSocket(this.wsUrl);
    socket.on("message", (data) => {
      try {
        handler(JSON.parse(data.toString()) as Record<string, unknown>);
      } catch {
        handler({ type: "log", message: data.toString() });
      }
    });

    socket.on("error", (error) => onError(error as Error));
    return socket;
  }
}
