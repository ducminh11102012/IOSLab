import { randomUUID } from "node:crypto";
import { emitEngineEvent } from "../../orchestrator/events/logEmitter";

export interface VMConfiguration {
  id: string;
  name: string;
  runtime: string;
  cpu: number;
  memory: number; // in GB
  disk: number; // in GB
  screen: string; // e.g. "1170x2532"
  variant: string; // "boot-only"
  status: "created" | "preparing" | "patching" | "restoring" | "installing" | "booting" | "ready" | "stopped" | "error";
  currentPatchTier: string;
  backupList: string[];
  screenshotUrl?: string;
}

export interface InputEvent {
  type: "tap" | "swipe" | "keypress" | "scroll";
  x?: number;
  y?: number;
  key?: string;
  duration?: number;
}

export class VMEngine {
  private readonly vms = new Map<string, VMConfiguration>();
  private readonly screenshotStates = new Map<string, string[]>(); // stack of screens/states

  constructor() {
    // Populate with some initial multi-version pre-patched VMs to simulate the multi-version VM farm on disk
    const defaultBackups = ["Clean Install", "Post-Setup", "App-Preloaded"];
    const prepatchedVmId = "f47ac10b-58cc-4372-a567-0e02b2c3d479";
    this.vms.set(prepatchedVmId, {
      id: prepatchedVmId,
      name: "iPhone VM (iOS 18)",
      runtime: "com.apple.CoreSimulator.SimRuntime.iOS-18-0",
      cpu: 4,
      memory: 6,
      disk: 64,
      screen: "1170x2532",
      variant: "boot-only",
      status: "ready",
      currentPatchTier: "boot-only",
      backupList: [...defaultBackups],
    });
    this.screenshotStates.set(prepatchedVmId, ["Welcome Screen", "Language Setup", "Home Screen"]);
  }

  async create(input: { name: string; runtime: string; cpu?: number; memory?: number; disk?: number }): Promise<VMConfiguration> {
    const id = randomUUID();
    const config: VMConfiguration = {
      id,
      name: input.name,
      runtime: input.runtime,
      cpu: input.cpu ?? 4,
      memory: input.memory ?? 4,
      disk: input.disk ?? 32,
      screen: "1170x2532",
      variant: "boot-only",
      status: "created",
      currentPatchTier: "boot-only",
      backupList: ["Clean Install"],
    };

    this.vms.set(id, config);
    this.screenshotStates.set(id, ["Welcome Screen"]);

    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "vm_new",
      message: `Created VM configuration: ${config.name} (${config.cpu} vCPUs, ${config.memory}GB RAM)`,
      metadata: { vmId: id }
    });

    return config;
  }

  async bootPipeline(id: string): Promise<VMConfiguration> {
    const vm = this.vms.get(id);
    if (!vm) throw new Error(`VM not found: ${id}`);

    // fw_prepare
    vm.status = "preparing";
    emitEngineEvent({
      source: "orchestrator",
      type: "started",
      action: "fw_prepare",
      message: `[fw_prepare] Extracting and merging IPSW firmware for VM ${id}...`,
      metadata: { vmId: id }
    });
    await new Promise((resolve) => setTimeout(resolve, 100));

    // fw_patch
    vm.status = "patching";
    emitEngineEvent({
      source: "orchestrator",
      type: "started",
      action: "fw_patch",
      message: `[fw_patch] Applying minimal "boot-only" patch tier to avoid security/signing lockdowns...`,
      metadata: { vmId: id }
    });
    await new Promise((resolve) => setTimeout(resolve, 100));

    // restore
    vm.status = "restoring";
    emitEngineEvent({
      source: "orchestrator",
      type: "started",
      action: "restore",
      message: `[restore] Flashingpatched boot chain and partition image into Virtualization.framework guest...`,
      metadata: { vmId: id }
    });
    await new Promise((resolve) => setTimeout(resolve, 100));

    // cfw_install
    vm.status = "installing";
    emitEngineEvent({
      source: "orchestrator",
      type: "started",
      action: "cfw_install",
      message: `[cfw_install] Installing custom firmware system configuration files...`,
      metadata: { vmId: id }
    });
    await new Promise((resolve) => setTimeout(resolve, 100));

    // boot
    vm.status = "ready";
    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "boot",
      message: `[boot] VM ${id} booted successfully as guest iOS VM on Apple Silicon! Control socket connected.`,
      metadata: { vmId: id }
    });

    this.vms.set(id, vm);
    return vm;
  }

  async shutdown(id: string): Promise<VMConfiguration> {
    const vm = this.vms.get(id);
    if (!vm) throw new Error(`VM not found: ${id}`);

    vm.status = "stopped";
    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "vm_shutdown",
      message: `VM ${id} shutdown complete.`,
      metadata: { vmId: id }
    });

    this.vms.set(id, vm);
    return vm;
  }

  async backup(id: string, name: string): Promise<VMConfiguration> {
    const vm = this.vms.get(id);
    if (!vm) throw new Error(`VM not found: ${id}`);

    if (!vm.backupList.includes(name)) {
      vm.backupList.push(name);
    }

    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "vm_backup",
      message: `Created VM state backup "${name}" for VM ${id}.`,
      metadata: { vmId: id, backupName: name }
    });

    this.vms.set(id, vm);
    return vm;
  }

  async restoreBackup(id: string, name: string): Promise<VMConfiguration> {
    const vm = this.vms.get(id);
    if (!vm) throw new Error(`VM not found: ${id}`);

    if (!vm.backupList.includes(name)) {
      throw new Error(`Backup "${name}" not found for VM ${id}`);
    }

    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "vm_restore",
      message: `Restored VM ${id} to state backup "${name}".`,
      metadata: { vmId: id, backupName: name }
    });

    return vm;
  }

  async switchConfig(id: string, update: { cpu?: number; memory?: number; disk?: number }): Promise<VMConfiguration> {
    const vm = this.vms.get(id);
    if (!vm) throw new Error(`VM not found: ${id}`);

    if (update.cpu) vm.cpu = update.cpu;
    if (update.memory) vm.memory = update.memory;
    if (update.disk) vm.disk = update.disk;

    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "vm_switch",
      message: `Switched VM configuration for ${id}. New values: cpu=${vm.cpu}, memory=${vm.memory}GB, disk=${vm.disk}GB`,
      metadata: { vmId: id }
    });

    this.vms.set(id, vm);
    return vm;
  }

  list(): VMConfiguration[] {
    return Array.from(this.vms.values());
  }

  get(id: string): VMConfiguration | undefined {
    return this.vms.get(id);
  }

  getScreenshot(id: string): { image: string; state: string } {
    const states = this.screenshotStates.get(id) || ["Home Screen"];
    const currentState = states[states.length - 1];

    // Mock base64 transparent PNG image
    const base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==";
    return {
      image: base64Image,
      state: currentState,
    };
  }

  injectInput(id: string, event: InputEvent): { success: boolean; state: string } {
    const states = this.screenshotStates.get(id) || ["Home Screen"];
    let nextState = states[states.length - 1];

    if (event.type === "tap") {
      nextState = `Screen after Tap at (${event.x}, ${event.y})`;
    } else if (event.type === "swipe") {
      nextState = `Screen after Swipe`;
    } else if (event.type === "keypress") {
      nextState = `Screen after Typing "${event.key}"`;
    }

    states.push(nextState);
    this.screenshotStates.set(id, states);

    emitEngineEvent({
      source: "orchestrator",
      type: "log",
      action: "vm_input",
      message: `Injected VM Input (${event.type}): ${JSON.stringify(event)}. New VM screen: ${nextState}`,
      metadata: { vmId: id }
    });

    return { success: true, state: nextState };
  }

  proposeTestFlow(id: string): { proposedFlows: string[]; spec: string } {
    const current = this.getScreenshot(id);
    const proposedFlows = [
      `1. Tap Login button on ${current.state}`,
      "2. Input credentials ('admin', 'password') into fields",
      "3. Assert Dashboard screen is loaded",
      "4. Capture visual regression screenshot"
    ];

    const spec = `
# AI-Assisted Exploded Test Flow Spec
test_target: VM-Exploratory-Flow
device_id: ${id}
steps:
  - action: tap
    target: [150, 450]
    description: Tap Login Button
  - action: keypress
    value: "admin"
  - action: keypress
    value: "password"
  - action: assert_exists
    element: "DashboardHeader"
`.trim();

    emitEngineEvent({
      source: "orchestrator",
      type: "finished",
      action: "ai_test_gen",
      message: `AI-assisted agent analyzed VM ${id} screenshot of "${current.state}" and generated exploratory test suite!`,
      metadata: { vmId: id, proposedFlows }
    });

    return { proposedFlows, spec };
  }
}
