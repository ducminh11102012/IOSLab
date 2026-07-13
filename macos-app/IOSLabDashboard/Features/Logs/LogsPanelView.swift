import SwiftUI

struct LogsPanelView: View {
    let logs: [String]

    var body: some View {
        GroupBox("Logs") {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 220)
        }
    }
}

// ==========================================
// CANVASES, EDITORS & UTILITY INSPECTORS (LogsPanelView Append)
// ==========================================

@MainActor
struct EditorView: View {
    let viewModel: DashboardViewModel
    @State private var codeText: String = """
import Foundation
import Virtualization

/// Hybrid Orchestration VM Lifecycle engine
public final class VMEngine {
    private let virtualMachine: VZVirtualMachine?
    private let patchTier = "boot-only"

    public init() {
        self.virtualMachine = nil
        print("VMEngine loaded with patch tier: \\(patchTier)")
    }

    public func bootPipeline() async throws {
        // [fw_prepare] -> [fw_patch] -> [restore]
        print("Executing firmware pipeline...")
    }
}
"""
    @State private var showingAutocomplete = false
    @State private var selectedAutocomplete = "bootPipeline()"

    let autocompleteSuggestions = [
        "bootPipeline() -> Void",
        "shutdown() -> Void",
        "createBackup(name: String)",
        "restoreBackup(name: String)",
        "switchConfig(cpu: Int, ram: Int)"
    ]

    var body: some View {
        GroupBox("Native Source Editor (SourceKit-LSP Integration)") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                    Text("Sources/VMEngine.swift")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    Spacer()
                    Text("SourceKit-LSP: Active")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }

                Divider()

                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 4) {
                        ForEach(1...18, id: \.self) { line in
                            HStack {
                                if line == 12 {
                                    Image(systemName: "exclamationmark.octagon.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(line)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(height: 14)
                        }
                    }
                    .frame(width: 20)
                    .padding(.top, 4)

                    VStack(alignment: .leading, spacing: 0) {
                        TextEditor(text: $codeText)
                            .font(.system(size: 12, design: .monospaced))
                            .frame(height: 250)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                            .onChange(of: codeText) { newValue in
                                if newValue.hasSuffix(".") {
                                    showingAutocomplete = true
                                }
                            }

                        if showingAutocomplete {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LSP Autocomplete Suggestions:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.purple)

                                ForEach(autocompleteSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        codeText += suggestion
                                        showingAutocomplete = false
                                        viewModel.logs.append("Completed code with LSP: \(suggestion)")
                                    }) {
                                        Text("• \(suggestion)")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.primary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                            .padding(.top, 8)
                        }
                    }
                }

                Divider()

                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text("VMEngine.swift:12:13: Error: Use of unresolved identifier 'VZVirtualMachine'")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.red)
                        Text("Fix-it: Import Virtualization framework or verify build settings")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Fix-it") {
                        codeText = "import Virtualization\n" + codeText
                        viewModel.logs.append("Applied automatic diagnostic Fix-it on VMEngine.swift")
                    }
                    .tint(.red)
                    .controlSize(.small)
                }
                .padding(8)
                .background(Color.red.opacity(0.05))
                .cornerRadius(6)
            }
        }
    }
}

@MainActor
struct PreviewsView: View {
    let viewModel: DashboardViewModel
    @State private var isRebuilding = false
    @State private var previewState = "Ready"
    @State private var rebuildProgress: Double = 0.0

    var body: some View {
        GroupBox("SwiftUI Canvas Live Preview (Hot-Reload Viewport)") {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "livephoto")
                        .foregroundColor(.pink)
                    Text("Canvas Previews: VMEngineView")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()

                    if isRebuilding {
                        HStack(spacing: 6) {
                            ProgressView(value: rebuildProgress, total: 1.0)
                                .frame(width: 80)
                            Text("Rebuilding...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            triggerRebuildRelaunch()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Resume / Force Reload")
                            }
                            .font(.system(size: 10))
                        }
                        .tint(.pink)
                    }
                }

                Divider()

                ZStack {
                    Color.black
                        .frame(width: 200, height: 400)
                        .cornerRadius(12)

                    VStack(spacing: 20) {
                        Image(systemName: "livephoto.play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                            .foregroundColor(.pink)

                        Text("VMEngineView Preview")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)

                        Text("State: \(previewState)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.pink)

                        Text("Pinch / Scroll to zoom canvas")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }

                    if isRebuilding {
                        Color.black.opacity(0.6)
                            .frame(width: 200, height: 400)
                            .cornerRadius(12)

                        VStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Relaunching viewport via control socket...")
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink.opacity(0.2), lineWidth: 2)
                )
            }
        }
    }

    private func triggerRebuildRelaunch() {
        isRebuilding = true
        rebuildProgress = 0.0
        viewModel.logs.append("Triggered swift dynamic rebuild & relaunch preview pipeline.")

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            rebuildProgress += 0.2
            if rebuildProgress >= 1.0 {
                timer.invalidate()
                isRebuilding = false
                previewState = "Live Screen Active"
                viewModel.logs.append("Preview hot-reload complete. Streamed live guest VM screenshot.")
            }
        }
    }
}

@MainActor
struct SwiftPlaygroundREPLView: View {
    let viewModel: DashboardViewModel
    @State private var inputCode: String = "let score = [4, 5, 2].reduce(0, +)\nprint(\"Total sum: \\(score)\")"
    @State private var replOutput: String = "Total sum: 11"

    var body: some View {
        GroupBox("Swift Playgrounds REPL Snippets") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                    Text("Interactive Swift Playground REPL")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                    Button("Run Code Snippet") {
                        executeSnippet()
                    }
                    .tint(.green)
                    .controlSize(.small)
                }

                Divider()

                TextEditor(text: $inputCode)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(height: 120)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)

                Divider()

                Text("CONSOLE REPL STANDARD OUTPUT:")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)

                Text(replOutput)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(4)
            }
        }
    }

    private func executeSnippet() {
        viewModel.logs.append("Executing interactive Swift snippet in REPL Playground.")
        if inputCode.contains("reduce") {
            replOutput = "Total sum: 11"
        } else {
            replOutput = "Success (evaluated in 12ms)"
        }
    }
}

@MainActor
struct InspectorView: View {
    let selectedDevice: DeviceModel?
    let selectedJob: JobModel?
    let viewModel: DashboardViewModel
    @Binding var inspectorTab: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                InspectorTabButton(icon: "info.circle", activeIcon: "info.circle.fill", tag: "attributes", current: $inspectorTab)
                    .help("Attributes Inspector")
                InspectorTabButton(icon: "checklist.checked", activeIcon: "checklist.checked", tag: "test", current: $inspectorTab)
                    .help("Test History Utilities")
                InspectorTabButton(icon: "photo.on.rectangle", activeIcon: "photo.on.rectangle.fill", tag: "diff", current: $inspectorTab)
                    .help("Visual Regression Metrics")
                InspectorTabButton(icon: "terminal", activeIcon: "terminal.fill", tag: "lldb", current: $inspectorTab)
                    .help("LLDB Debugger Console")
                InspectorTabButton(icon: "leaf", activeIcon: "leaf.fill", tag: "sustainability", current: $inspectorTab)
                    .help("Sustainability Energy Report")
                InspectorTabButton(icon: "gear", activeIcon: "gear", tag: "preferences", current: $inspectorTab)
                    .help("Preferences Theme Layout")
                InspectorTabButton(icon: "internaldrive", activeIcon: "internaldrive.fill", tag: "storage", current: $inspectorTab)
                    .help("Storage Cleanups Metrics")
                InspectorTabButton(icon: "play.circle", activeIcon: "play.circle.fill", tag: "actions", current: $inspectorTab)
                    .help("Quick Actions")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let device = selectedDevice {
                        switch inspectorTab {
                        case "attributes":
                            AttributesInspectorTab(device: device)

                        case "test":
                            TestHistoryInspectorTab(device: device, job: selectedJob)

                        case "diff":
                            VisualDiffInspectorTab(device: device)

                        case "lldb":
                            LLDBDebuggerView(viewModel: viewModel)

                        case "sustainability":
                            SustainabilityEnergyView(viewModel: viewModel)

                        case "preferences":
                            PreferencesView(viewModel: viewModel)

                        case "storage":
                            StorageDashboardView(viewModel: viewModel)

                        case "actions":
                            QuickActionsInspectorTab(device: device, viewModel: viewModel)

                        default:
                            Text("No Inspector Tab Selected")
                        }
                    } else if inspectorTab == "lldb" {
                        LLDBDebuggerView(viewModel: viewModel)
                    } else if inspectorTab == "sustainability" {
                        SustainabilityEnergyView(viewModel: viewModel)
                    } else if inspectorTab == "preferences" {
                        PreferencesView(viewModel: viewModel)
                    } else if inspectorTab == "storage" {
                        StorageDashboardView(viewModel: viewModel)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "sidebar.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Select a device from the pool to view detailed Inspector metrics and trigger contextual actions.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InspectorTabButton: View {
    let icon: String
    let activeIcon: String
    let tag: String
    @Binding var current: String

    var body: some View {
        Button(action: {
            current = tag
        }) {
            Image(systemName: current == tag ? activeIcon : icon)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(current == tag ? .accentColor : .secondary)
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
    }
}

struct AttributesInspectorTab: View {
    let device: DeviceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IDENTITY & WORKSPACE")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            InspectorInfoRow(label: "Device Name", value: device.name)
            InspectorInfoRow(label: "Device ID", value: device.id)
            InspectorInfoRow(label: "OS Runtime", value: device.runtime)
            InspectorInfoRow(label: "Type", value: device.type?.uppercased() ?? "SIMULATOR")

            Divider()

            Text("PERFORMANCE & RESOURCE PRESSURES")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            InspectorInfoRow(label: "Status State", value: device.status.uppercased())
            InspectorInfoRow(label: "vCPU Cores", value: "\(device.cpu ?? 4) Cores")
            InspectorInfoRow(label: "Memory RAM", value: "\(device.memory ?? 6) GB")
            InspectorInfoRow(label: "Virtual Disk", value: "\(device.disk ?? 64) GB")
            InspectorInfoRow(label: "Display Resolution", value: device.screen ?? "1170x2532")

            Divider()

            Text("FIRMWARE DETAILS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            InspectorInfoRow(label: "Variant Set", value: device.variant ?? "boot-only")
            InspectorInfoRow(label: "Patch Tier", value: device.currentPatchTier ?? "boot-only (stable)")
            InspectorInfoRow(label: "Uptime Speed", value: "24m 12s")
        }
    }
}

struct TestHistoryInspectorTab: View {
    let device: DeviceModel
    let job: JobModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TEST SUITE SUMMARY")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            InspectorInfoRow(label: "Associated Target", value: job?.testTarget ?? "AppTests")
            InspectorInfoRow(label: "Flake Index", value: "1.2% (Very Low)")
            InspectorInfoRow(label: "Total Shards", value: "1 of 4")

            Divider()

            Text("HISTORICAL RUN DURATIONS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach([12, 18, 14, 16, 11], id: \.self) { val in
                    VStack {
                        Text("\(val)s")
                            .font(.system(size: 7, design: .monospaced))
                            .foregroundColor(.secondary)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: 24, height: CGFloat(val * 2))
                    }
                }
            }
            .frame(height: 52)
            .padding(.top, 6)

            Divider()

            Text("MATRIX FLAKE CHART")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundColor(.blue)
                Text("Stable (98.8% success rate across runtimes)")
                    .font(.caption2)
            }
        }
    }
}

struct VisualDiffInspectorTab: View {
    let device: DeviceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PIXEL DIFFERENCE METRICS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            InspectorInfoRow(label: "Total Pixel Shift", value: "0.12% difference")
            InspectorInfoRow(label: "Affected Regions", value: "3 clusters found")
            InspectorInfoRow(label: "Match Verdict", value: "PASSED (Below 1.0% tolerance)")

            Divider()

            Text("THUMBNAIL COMPARE OVERVIEW")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            HStack {
                VStack {
                    Text("Baseline")
                        .font(.system(size: 8, weight: .semibold))
                    Color.gray.opacity(0.1)
                        .frame(width: 80, height: 120)
                        .cornerRadius(4)
                        .overlay(Image(systemName: "photo").foregroundColor(.secondary))
                }

                Spacer()

                VStack {
                    Text("Current")
                        .font(.system(size: 8, weight: .semibold))
                    Color.purple.opacity(0.15)
                        .frame(width: 80, height: 120)
                        .cornerRadius(4)
                        .overlay(Image(systemName: "photo.fill").foregroundColor(.purple))
                }
            }
        }
    }
}

struct QuickActionsInspectorTab: View {
    let device: DeviceModel
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONTEXTUAL QUICK ACTIONS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)

            Button(action: {
                viewModel.logs.append("Triggered hot restart on device: \(device.name)")
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Restart Device Session")
                    Spacer()
                }
                .font(.system(size: 11, weight: .medium))
                .padding(8)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            Button(action: {
                viewModel.logs.append("Captured on-demand viewport screenshot of [\(device.name)] (Saved to artifacts)")
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Take Live Screenshot")
                    Spacer()
                }
                .font(.system(size: 11, weight: .medium))
                .padding(8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            Button(action: {
                viewModel.logs.append("Opened terminal shell console connection to [\(device.id)]")
            }) {
                HStack {
                    Image(systemName: "terminal")
                    Text("Open Interactive Shell")
                    Spacer()
                }
                .font(.system(size: 11, weight: .medium))
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

            Button(action: {
                viewModel.logs.append("Promoted actual screenshot of [\(device.name)] as the new master baseline reference.")
            }) {
                HStack {
                    Image(systemName: "checkmark.seal")
                    Text("Promote as New Master Baseline")
                    Spacer()
                }
                .font(.system(size: 11, weight: .semibold))
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }
}

struct InspectorInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

@MainActor
struct LLDBDebuggerView: View {
    let viewModel: DashboardViewModel
    @State private var lldbCommand: String = ""
    @State private var lldbHistory: [String] = [
        "(lldb) target create \"build/Build/Products/Debug-iphonesimulator/iOSLab.app\"",
        "Current executable set to 'build/Build/Products/Debug-iphonesimulator/iOSLab.app' (arm64).",
        "(lldb) breakpoint set --file VMEngine.swift --line 12",
        "Breakpoint 1: where = iOSLab`VMEngine.init() + 24 at VMEngine.swift:12, address = 0x00000001004a0e3c"
    ]
    @State private var showingQuickHelp = false
    @State private var selectedCertificate = "Apple Development: developer@ioslab.org (7F2B1A)"

    let certificates = [
        "Apple Development: developer@ioslab.org (7F2B1A)",
        "Apple Distribution: enterprise@ioslab.org (3A9C8D)",
        "Local Development: Ad-Hoc Self-Signed"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("LLDB Native Target Debugger") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACTIVE BREAKPOINTS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "breakpoint.fill")
                            .foregroundColor(.blue)
                        Text("VMEngine.swift : Line 12")
                            .font(.system(size: 10, design: .monospaced))
                        Spacer()
                        Text("Active")
                            .font(.system(size: 8))
                            .foregroundColor(.green)
                    }

                    Divider()

                    Text("LOCAL VARIABLE REGISTERS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Text("self")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("VMEngine (0x0000000104b2c)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("patchTier")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("\"boot-only\"")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text("LLDB INTERACTIVE REPL CONSOLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(lldbHistory, id: \.self) { history in
                            Text(history)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(history.hasPrefix("(lldb)") ? .blue : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(4)

                    HStack {
                        TextField("lldb command", text: $lldbCommand, onCommit: {
                            if !lldbCommand.isEmpty {
                                lldbHistory.append("(lldb) " + lldbCommand)
                                executeLldbCommand(lldbCommand)
                                lldbCommand = ""
                            }
                        })
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.small)

                        Button("Execute") {
                            if !lldbCommand.isEmpty {
                                lldbHistory.append("(lldb) " + lldbCommand)
                                executeLldbCommand(lldbCommand)
                                lldbCommand = ""
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }

            GroupBox("Quick Help & Swift Documentation") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Documentation: public VMEngine")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Text("A premium virtualization state controller orchestrating genuine iOS guest images on local M-series Apple Silicon machines.")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showingQuickHelp.toggle()
                        viewModel.logs.append("Opened full DocC documentation reader panel.")
                    }) {
                        Text("Show Full DocC Document Page")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .buttonStyle(.borderless)
                }
            }

            GroupBox("Signing & Profiles Capabilities") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.orange)
                        Text("Provisioning Profiles & Certificates")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Picker("Signing Certificate", selection: $selectedCertificate) {
                        ForEach(certificates, id: \.self) { cert in
                            Text(cert).tag(cert)
                        }
                    }
                    .pickerStyle(.menu)
                    .controlSize(.small)

                    Toggle("Automatically manage signing", isOn: .constant(true))
                        .font(.caption2)

                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("Hardware Sandbox Capabilities Enabled")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func executeLldbCommand(_ cmd: String) {
        viewModel.logs.append("LLDB Command executed: [\(cmd)]")
        if cmd == "po self" {
            lldbHistory.append("VMEngine instance: { patchTier: \"boot-only\", virtualMachine: null }")
        } else if cmd == "continue" || cmd == "c" {
            lldbHistory.append("Process resumed. Hit next breakpoint/run.")
        } else {
            lldbHistory.append("Unknown command: [\(cmd)]. po self, continue supported in simulator.")
        }
    }
}
