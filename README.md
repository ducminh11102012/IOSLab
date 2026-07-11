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
- **Device/OS matrix testing** — validate a combination of device models (iPhone SE through Pro Max) and iOS versions (15–18) in one run.
- **Visual regression detection** — capture a screenshot per state and diff it against a baseline.
- **Cross-version diffing** — surface layout, animation, and OS-specific differences between iOS versions.
- **Test orchestration** — describe the desired device/OS coverage declaratively; iOSLab handles scheduling, retries, and load balancing.
- **Local CI pipeline** — run build, test, validate, and report steps locally without an external CI queue.
- **Dashboard** — a live view of the device grid, logs, system load, and test status.
- **REST API** — trigger and monitor runs programmatically for integration with CI/CD or internal tooling.
- **Resource-aware scheduling** — adapts simulator concurrency to available CPU and memory.

## Requirements

- macOS
- Xcode
- 16 GB RAM minimum (32 GB+ recommended for high device counts)

## Installation

### Option 1: Prebuilt release (recommended)

Precompiled application bundles and CLI tools are available on the [Releases page](https://github.com/yourname/ioslab/releases). Download the latest release and run it directly — no build step required.

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
