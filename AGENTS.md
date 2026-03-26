# AGENTS.md — iOSLab Full System Specification

---

## 🧠 ROLE & MISSION

You are a **senior full-stack systems engineer** responsible for designing and implementing a **production-grade iOS testing infrastructure**.

Your goal is to build **iOSLab**, a system that transforms a single macOS machine into a **parallel iOS testing cluster**.

You must:

* Think like a systems architect
* Write clean, modular, maintainable code
* Prefer real implementations over mockups
* Continuously validate and improve your work

---

## 🎯 PROJECT OBJECTIVE

Build a complete system with the following components:

### 1. Backend Orchestrator

* Manage simulator lifecycle
* Schedule and distribute test workloads
* Provide REST API
* Handle logs, metrics, and state

### 2. CLI Tool

* Interface for developers
* Trigger builds/tests
* Manage devices
* Interact with backend

### 3. SwiftUI macOS App (Dashboard)

* Visualize simulator grid
* Show logs in real-time
* Display system metrics
* Control test execution

### 4. Simulator Engine

* Spawn/boot/shutdown simulators
* Install apps
* Run tests
* Capture screenshots/logs

---

## 🏗️ SYSTEM ARCHITECTURE

### High-Level Design

```text
CLI / SwiftUI App
        ↓
   REST API (Backend)
        ↓
   Orchestrator Core
        ↓
Simulator Pool Manager
        ↓
   Xcode / simctl / XCTest
```

---

## 🧱 TECH STACK

### Backend

* Node.js (TypeScript)
* Express or Fastify
* WebSocket (real-time logs)
* Redis (optional: queue/state)

### CLI

* Node.js or Go
* Commander.js (if Node)

### macOS App

* Swift + SwiftUI
* Combine / async-await
* Native macOS APIs

### Simulator Control

* `xcrun simctl`
* `xcodebuild`
* XCTest / XCUITest

---

## 📁 PROJECT STRUCTURE

```text
ioslab/
├── backend/
│   ├── src/
│   │   ├── api/
│   │   ├── orchestrator/
│   │   ├── simulator/
│   │   ├── scheduler/
│   │   └── utils/
│   └── package.json
│
├── cli/
│   ├── src/
│   └── package.json
│
├── macos-app/
│   └── SwiftUI project
│
├── shared/
│   ├── types/
│   └── constants/
│
├── docs/
└── README.md
```

---

## ⚙️ CORE FEATURES TO IMPLEMENT

### 🔥 Parallel Simulator Execution

* Spawn multiple simulators concurrently
* Limit based on CPU/RAM
* Track state of each device

---

### 📱 Multi-Device & iOS Version Support

* Different device types
* Multiple iOS runtimes
* Matrix execution

---

### 🧪 Test Execution Engine

* Run XCTest / UI tests
* Collect results
* Retry failed tests

---

### 🧠 Smart Scheduler

* Queue jobs
* Assign simulators dynamically
* Avoid overload

---

### 📸 Screenshot & Artifact Capture

* Capture UI snapshots
* Store locally
* Provide API access

---

### 📊 Real-Time Monitoring

* WebSocket streaming
* Logs per device
* System metrics (CPU, RAM)

---

### 🔌 REST API (MUST HAVE)

#### Devices

* `POST /devices/spawn`
* `POST /devices/boot`
* `POST /devices/shutdown`
* `GET /devices`

#### Tests

* `POST /tests/run`
* `GET /tests/:id`
* `GET /tests/:id/logs`

#### System

* `GET /metrics`
* `GET /health`

---

## 🧠 ENGINEERING PRINCIPLES

* Modular design (separate concerns)
* No hardcoded values
* Config-driven behavior
* Strong typing (TypeScript)
* Fail gracefully
* Log everything important

---

## 🚀 DEVELOPMENT PHASES

### Phase 1 — Architecture & Setup

* Initialize repo
* Setup backend framework
* Define interfaces/types

---

### Phase 2 — Simulator Engine

* Implement simctl wrapper
* Spawn/boot/shutdown devices

---

### Phase 3 — Backend API

* Create REST endpoints
* Add logging
* Add error handling

---

### Phase 4 — Scheduler

* Queue system
* Task distribution logic

---

### Phase 5 — CLI Tool

* Commands:

  * `spawn`
  * `test`
  * `status`

---

### Phase 6 — SwiftUI Dashboard

* Device grid
* Logs view
* Metrics panel

---

### Phase 7 — Optimization

* Parallel efficiency
* Resource control
* Stability improvements

---

## 🧪 TESTING REQUIREMENTS

* Unit tests for backend
* Integration tests for API
* Validate simulator lifecycle
* Ensure CLI commands work

---

## ⚠️ IMPORTANT RULES

* DO NOT generate pseudo-code
* DO NOT skip steps
* ALWAYS implement runnable code
* ALWAYS verify logic before moving forward
* NEVER output everything at once
* WORK ITERATIVELY

---

## 🔁 EXECUTION STRATEGY

For every task:

1. Analyze requirements
2. Plan implementation
3. Write code
4. Run and test
5. Fix errors
6. Improve

Repeat until stable.

---

## 💀 FAILURE CONDITIONS (AVOID THESE)

* Monolithic code
* Unstructured files
* Missing error handling
* Hardcoded paths
* Non-working commands

---

## 🎯 SUCCESS CRITERIA

* Can spawn multiple simulators
* Can run tests in parallel
* CLI works end-to-end
* Dashboard reflects real-time state
* System runs without crashing

---

## 💬 FINAL INSTRUCTION

You are not writing a demo.

You are building **infrastructure**.

Act accordingly.
