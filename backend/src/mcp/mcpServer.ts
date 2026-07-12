import { OrchestratorService } from "../orchestrator/services/orchestratorService";

export interface McpRequest {
  jsonrpc: string;
  id: string | number;
  method: string;
  params?: any;
}

export interface McpResponse {
  jsonrpc: string;
  id: string | number;
  result?: any;
  error?: any;
}

export class McpServer {
  constructor(private readonly orchestrator: OrchestratorService) {}

  public async handleRequest(request: McpRequest): Promise<McpResponse> {
    const { id, method, params } = request;

    try {
      switch (method) {
        case "initialize":
          return {
            jsonrpc: "2.0",
            id,
            result: {
              protocolVersion: "2024-11-05",
              capabilities: {
                tools: {}
              },
              serverInfo: {
                name: "ioslab-mcp-server",
                version: "2.0.0"
              }
            }
          };

        case "tools/list":
          return {
            jsonrpc: "2.0",
            id,
            result: {
              tools: [
                {
                  name: "list_devices",
                  description: "List all unified devices (Simulators and VMs) in the pool.",
                  inputSchema: { type: "object", properties: {} }
                },
                {
                  name: "spawn_device",
                  description: "Spawn a new device (Simulator or VM).",
                  inputSchema: {
                    type: "object",
                    properties: {
                      name: { type: "string", description: "Name of device" },
                      runtime: { type: "string", description: "iOS Runtime version" },
                      type: { type: "string", enum: ["simulator", "vm"], description: "Device type" },
                      cpu: { type: "number", description: "vCPU count (VM only)" },
                      memory: { type: "number", description: "Memory in GB (VM only)" }
                    },
                    required: ["name", "runtime"]
                  }
                },
                {
                  name: "run_test",
                  description: "Run a test target on a compatible device.",
                  inputSchema: {
                    type: "object",
                    properties: {
                      testTarget: { type: "string", description: "The test target scheme (e.g. AppTests)" }
                    },
                    required: ["testTarget"]
                  }
                },
                {
                  name: "get_screenshot",
                  description: "Get a live screenshot of a virtualized real-iOS VM instance.",
                  inputSchema: {
                    type: "object",
                    properties: {
                      id: { type: "string", description: "The VM Device ID" }
                    },
                    required: ["id"]
                  }
                },
                {
                  name: "inject_input",
                  description: "Inject tap, swipe, keypress, or scroll gesture into a VM instance.",
                  inputSchema: {
                    type: "object",
                    properties: {
                      id: { type: "string", description: "The VM Device ID" },
                      type: { type: "string", enum: ["tap", "swipe", "keypress", "scroll"] },
                      x: { type: "number" },
                      y: { type: "number" },
                      key: { type: "string" }
                    },
                    required: ["id", "type"]
                  }
                },
                {
                  name: "inject_chaos",
                  description: "Inject controlled failure conditions such as network loss, clock offsets, or thermal limiting.",
                  inputSchema: {
                    type: "object",
                    properties: {
                      id: { type: "string", description: "The VM Device ID" },
                      networkProfile: { type: "string", enum: ["Wi-Fi", "3G", "2G", "No-Network"] },
                      thermalThrottle: { type: "boolean" },
                      systemClockOffset: { type: "number" }
                    },
                    required: ["id"]
                  }
                },
                {
                  name: "simulate_device_aging",
                  description: "Simulate device wear and tear including battery degradation and disk filling.",
                  inputSchema: {
                    type: "object",
                    properties: {
                      id: { type: "string", description: "The VM Device ID" },
                      batteryDegraded: { type: "boolean" },
                      diskFullLevel: { type: "number" }
                    },
                    required: ["id"]
                  }
                }
              ]
            }
          };

        case "tools/call": {
          const { name, arguments: args } = params;
          const result = await this.executeTool(name, args);
          return {
            jsonrpc: "2.0",
            id,
            result: {
              content: [
                {
                  type: "text",
                  text: JSON.stringify(result, null, 2)
                }
              ]
            }
          };
        }

        default:
          return {
            jsonrpc: "2.0",
            id,
            error: {
              code: -32601,
              message: `Method not found: ${method}`
            }
          };
      }
    } catch (error: any) {
      return {
        jsonrpc: "2.0",
        id,
        error: {
          code: -32603,
          message: error.message || "Internal error"
        }
      };
    }
  }

  private async executeTool(name: string, args: any): Promise<any> {
    switch (name) {
      case "list_devices":
        return this.orchestrator.listDevices();

      case "spawn_device":
        return this.orchestrator.spawnDevice({
          name: args.name,
          runtime: args.runtime,
          type: args.type,
          cpu: args.cpu,
          memory: args.memory
        });

      case "run_test": {
        const job = this.orchestrator.enqueueTest({ testTarget: args.testTarget });
        const scheduled = await this.orchestrator.scheduleNext();
        return { job, scheduled };
      }

      case "get_screenshot":
        return this.orchestrator.vmEngine.getScreenshot(args.id);

      case "inject_input":
        return this.orchestrator.vmEngine.injectInput(args.id, {
          type: args.type,
          x: args.x,
          y: args.y,
          key: args.key
        });

      case "inject_chaos":
        return this.orchestrator.vmEngine.injectChaos(args.id, {
          networkProfile: args.networkProfile,
          thermalThrottle: args.thermalThrottle,
          systemClockOffset: args.systemClockOffset
        });

      case "simulate_device_aging":
        return this.orchestrator.vmEngine.simulateAging(args.id, {
          batteryDegraded: args.batteryDegraded,
          diskFullLevel: args.diskFullLevel
        });

      default:
        throw new Error(`Tool not found: ${name}`);
    }
  }
}
