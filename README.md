# iOSLab

iOSLab is a local testing platform for iOS applications that runs test suites across many iOS Simulator instances in parallel on a single Mac. It removes the bottleneck of sequential simulator testing by distributing execution across device and OS version combinations simultaneously.

## Table of Contents

- [Why iOSLab](#why-ioslab)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [API](#api)
- [Comparison](#comparison)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Why iOSLab

Standard iOS testing workflows run one simulator at a time. This makes cross-device and cross-version validation slow, and issues that only appear on specific device/OS combinations often surface in production instead of in CI.

iOSLab runs many simulator instances concurrently on the same machine, so a full device/OS matrix can be validated in a single pass instead of one run per configuration.

## Features

- **Parallel execution** — run tests across 20+ simulator instances concurrently.
- **Hybrid device platform** — run Simulator instances and real virtualized iOS instances (Apple Virtualization.framework) side-by-side.
- **Device/OS matrix testing** — validate a combination of device models (iPhone SE through Pro Max) and iOS versions (15–18) in one run.
- **Visual virtualization engine** — full boot pipeline (`fw_prepare` -> `fw_patch` -> `restore` -> `cfw_install` -> `boot`) to run genuine real iOS 18 on guest VMs.
- **Visual regression detection** — capture a screenshot per state and diff it against a baseline (fully supports VM screenshots).
- **Cross-version diffing** — surface layout, animation, and OS-specific differences between iOS versions.
- **Test orchestration** — describe the desired device/OS coverage declaratively; iOSLab handles scheduling, retries, and load balancing.
- **Model Context Protocol (MCP)** — expose the device pool as standard tools to LLM agents (e.g. Claude Code/Desktop).
- **AI-assisted exploratory tests** — automatically generate test flows and spec suites directly from live VM screenshots.
- **Local CI pipeline** — run build, test, validate, and report steps locally without an external CI queue.
- **Dashboard** — a live view of the device grid, logs, system load, and test status.
- **REST API** — trigger and monitor runs programmatically for integration with CI/CD or internal tooling.
- **Resource-aware scheduling** — adapts simulator and heavy VM concurrency to available CPU and memory using cost-weight resource intelligence.

## Requirements

- macOS
- Xcode
- 16 GB RAM minimum (32 GB+ recommended for high device counts)

## Installation

### Option 1: Prebuilt release (recommended)

Precompiled application bundles and CLI tools are available on the [Releases page](https://github.com/ducminh11102012/ioslab/releases). Download the latest release and run it directly — no build step required.

### Option 2: Build from source

Build from source if you plan to contribute or need to modify the system.

```bash
git clone https://github.com/yourname/ioslab
cd ioslab
make setup
```

To build without a connected simulator environment (e.g., in CI):

```bash
IOSLAB_SIMULATOR_MOCK=true ./scripts/build_release.sh
```

You can also point the build script at a specific repository and target directory:

```bash
./scripts/build_release.sh <repo_url> <target_dir>
```

## Quick Start

Run a test across 12 simulators:

```bash
ioslab test --devices=12
```

Run a full local CI pipeline:

```bash
ioslab run pipeline.yaml
```

## Usage

### Parallel test run

```bash
ioslab test --devices=32
```

Runs the test suite across 32 simulator instances concurrently.

### Matrix configuration

Define target devices and iOS versions declaratively:

```yaml
test:
  devices: 24
  ios_versions: [16, 17, 18]
```

iOSLab distributes the run across the specified matrix and handles retries and load balancing automatically.

## API

iOSLab exposes a REST API for integration with CI/CD systems and internal tools:

```
POST /devices/spawn
POST /tests/run
GET  /metrics
```

### v2 VM-Specific Endpoints
```
POST /vms/spawn          # Spawn a real virtualized iOS guest VM
GET  /vms                # List all virtualized guest VMs
GET  /vms/{id}/screenshot # Get a live base64 snapshot of the guest VM screen
POST /vms/{id}/input      # Inject tap, swipe, keypress, or scroll gesture
POST /vms/{id}/backup     # Create a saved state backup of guest VM
POST /vms/{id}/restore    # Restore VM state to a saved backup snapshot
POST /vms/{id}/switch     # Hot-swap CPU, memory, or disk specifications
POST /vms/{id}/agent/explore # Propose exploratory test flows using screenshots
POST /mcp                 # JSON-RPC 2.0 endpoint for the Model Context Protocol
```

## VM Lifecycle CLI Subcommands

iOSLab v2 introduces a first-class command group `vm` for complete guest VM lifecycle orchestrations, mirroring Simulator ergonomics:

```bash
# Create a new guest VM configuration on disk
ioslab vm new "iPhone 18 VM" --cpu 4 --memory 6 --disk 64

# Boot VM through firmware preparation, patching, and restore pipelines
ioslab vm boot <vmId>

# Snapshot/Backup VM state
ioslab vm backup <vmId> "Clean-Install"

# Restore VM to previously saved backup state
ioslab vm restore <vmId> "Clean-Install"

# Hot-swap CPU or Memory specifications of a running/stopped VM
ioslab vm switch <vmId> --cpu 8 --memory 12

# List all local virtualized iOS guest VMs on Apple Silicon
ioslab vm list
```

To dynamically spawn a VM via the unified `spawn` command, use the `--vm` flag:
```bash
ioslab spawn "My Guest iOS 18" --vm
```

## Model Context Protocol (MCP) Server

iOSLab v2 hosts a fully standard-compliant MCP server at `POST /mcp` (using JSON-RPC 2.0). LLM client agents (such as Claude Code or Claude Desktop) can connect and drive automated physical-like guest iOS VM testing directly:
- `list_devices`: lists unified device pools (Simulators and VMs).
- `spawn_device`: provisions and boots Simulator or VM.
- `run_test`: enqueues test targets.
- `get_screenshot`: grabs base64 live screen of virtualized real iOS.
- `inject_input`: sends touch/keyboard inputs.

---

## Migration & Compatibility Guide for v1 Users

iOSLab v2 is designed to be **strictly additive, 100% backward-compatible, and zero-configuration** for existing Simulator-only users.

### Backward-Compatible Defaults
- **Existing Commands Unmodified:** Commands like `ioslab test --devices=32` continue to execute 32 lightweight iOS Simulator instances backed by `xcrun simctl`.
- **Zero Configuration Needed:** If you do not explicitly opt-in to Virtualization, the platform behaves identically to v1, avoiding high CPU/disk footprints of running full iOS kernels.

### Explicit Opt-in for Real iOS VMs
VM testing is strictly opt-in and can be described declaratively in matrix YAML configurations or target flags:
```yaml
test:
  devices:
    - type: simulator
      count: 24
      ios_versions: [17, 18]
    - type: vm
      count: 4
      ios_versions: [18]
      variant: boot-only   # firmware minimal patch tier
```

### Resource Accounting and Cost Weights
- Running full iOS virtual machines incurs high overhead. iOSLab v2 incorporates resource-aware scheduling:
  - **Simulator cost weight:** `1` resource unit.
  - **VM cost weight:** `4` resource units.
- The orchestrator load-balancer automatically limits total active device weight based on host memory and CPU limits to prevent core throttling.

## Comparison

| | Traditional workflow | iOSLab |
|---|---|---|
| Execution model | Sequential | Parallel |
| Feedback loop | Slow | Fast |
| Device/OS coverage | One configuration per run | Full matrix per run |

## Roadmap

- Multi-Mac clustering
- Distributed execution across machines
- Physical device integration
- AI-generated test flows

## Contributing

Contributions are welcome, particularly around performance, scheduling, and developer experience. Please open an issue to discuss significant changes before submitting a pull request.

## License

This project is licensed under the [MIT License](LICENSE). See the `LICENSE` file for details.
