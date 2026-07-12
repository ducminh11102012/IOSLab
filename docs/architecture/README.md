# iOSLab v2 — Hybrid Virtualization Platform Architecture

This document details the software architecture design and data flows for **iOSLab v2**, which introduces full iOS Guest VM Virtualization alongside standard iOS Simulator orchestration on macOS Apple Silicon.

## 1. High-Level Architectural Diagram

```
                     ┌────────────────────┐
                     │   Test Orchestrator │
                     └─────────┬───────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │       Device Pool Manager   │
                 └──────┬───────────────┬──────┘
                         │               │
            ┌────────────▼───┐   ┌───────▼────────────┐
            │ Simulator Adapter│   │   VM Adapter        │
            │ (simctl backend) │   │ (Virtualization.fw) │
            └──────────────────┘   └──────────┬───────────┘
                                               │
                                    ┌──────────▼──────────┐
                                    │  Firmware Pipeline    │
                                    │ (fetch/patch/restore) │
                                    └───────────────────────┘

  Dashboard (Web UI)  ──┐
  REST API              ├──► Test Orchestrator
  MCP Server             ┘
```

---

## 2. Subsystems & Components

### 2.1 Unified Device Pool Manager
The device pool manager provides a single polymorphic abstraction layer (`Device`) so the scheduler and orchestrator can treat iOS Simulators and real iOS Guest VMs transparently:
- **Simulator Adapter:** Interfaces with `xcrun simctl` command runners.
- **VM Adapter:** Interfaces with Apple's `Virtualization.framework` guest kernels and custom PCC research virtual machines.

### 2.2 VM Virtualization Engine (`VMEngine`)
An additive engine built specifically to spin up genuine guest iOS kernels.
- **VM Configuration Manifest:** Declared dynamically or saved in plist structures containing hardware profiles (vCPUs, memory allocation, virtual disk size, display resolutions).
- **Control Channel Socket:** Exposes touch input injection, text typing keypresses, clipboard sharing, and live viewport screenshots.

### 2.3 Firmware Pipeline (`FirmwarePipeline`)
A sequence of low-level phases scoping firmware images from raw Apple IPSW releases to automatable VM system states:
1. `fw_prepare` — extraction and alignment of IPSW files.
2. `fw_patch` — application of "boot-only" minimalist kernel patches to bypass secure boot restrictions without jailbreaking sandbox permissions.
3. `restore` — flashing patched partition images into guest system drives.
4. `cfw_install` — customized system-level workspace file pre-configurations.
5. `boot` — physical launch of virtual machine and control socket establishment.

### 2.4 Resource-Aware Cost Scheduler
Guest virtual machines are far heavier than lightweight simulator wrappers. To prevent host system choking:
- Simulators are assigned a cost weight of `1`.
- Guest iOS VMs are assigned a cost weight of `4`.
- The scheduler computes `getActiveLoad(devices)` dynamically, scheduling next queued tests only if `activeLoad + compatibleDeviceCost <= hostCapacity`.

### 2.5 Model Context Protocol (MCP) Server
An open standard integration of JSON-RPC tools exposing device control directly to modern LLM developer assistants:
- `list_devices`: query simulators and VMs.
- `spawn_device`: hot-provisioning.
- `run_test`: test targets.
- `get_screenshot` / `inject_input`: drive automated VM sessions.

---

## 3. Core Data Flow: Spawning VM and Pipeline Boot

```
[ Client ]          [ API Server ]     [ Orchestrator ]     [ VM Engine ]      [ Control Socket ]
    │                    │                    │                    │                   │
    ├─► Spawn VM (POST) ─┼───────────────────►│                    │                   │
    │                    │                    ├─► Create Config ──►│                   │
    │                    │                    │                    ├─► [fw_prepare]    │
    │                    │                    │                    ├─► [fw_patch]      │
    │                    │                    │                    ├─► [restore]       │
    │                    │                    │                    ├─► [cfw_install]   │
    │                    │                    │                    ├─► [boot]          │
    │                    │                    │                    │                   │
    │                    │                    │                    ├─► Connect ───────►│
    │◄─ Device Spawned ──┼◄───────────────────┤◄───────────────────┤                   │
```
