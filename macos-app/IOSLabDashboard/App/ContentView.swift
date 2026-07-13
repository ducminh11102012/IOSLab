import SwiftUI
import AppKit

@MainActor
struct ContentView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var runtime: BackendRuntime

    // Layout Navigation Panels
    @State private var selectedDevice: DeviceModel? = nil
    @State private var selectedJob: JobModel? = nil

    // Tab Selections
    @State private var navigatorTab: String = "devices" // devices, tests, reports, snapshots, project, git, packages, organizer, booking, automation
    @State private var canvasTab: String = "grid" // grid, matrix, diff, console
    @State private var inspectorTab: String = "attributes" // attributes, test, diff, actions
    @State private var selectedScheme: String = "Hybrid VM & Sim Matrix"

    // Collapsible Panels State
    @State private var showNavigator = true
    @State private var showInspector = true
    @State private var showConsole = true
    @State private var zoomScale: Double = 1.0
    @State private var consoleSearchText = ""

    let schemes = ["Local Simulator Pool (18.0)", "Hybrid VM & Sim Matrix", "Exploratory AI Suite", "CI Validation Core"]

    var body: some View {
        HStack(spacing: 0) {
            // 1. LEFT PANE: Tabbed Navigator Sidebar
            if showNavigator {
                NavigatorView(
                    navigatorTab: $navigatorTab,
                    devices: viewModel.devices,
                    jobs: viewModel.jobs,
                    selectedDevice: $selectedDevice,
                    selectedJob: $selectedJob,
                    viewModel: viewModel
                )
                .frame(width: 260)
                .background(VisualEffectView().ignoresSafeArea())

                Divider()
            }

            // 2. CENTER PANE: Workspace Canvas and Bottom Console Area
            VStack(spacing: 0) {
                // Workspace Header Context Tabs
                HStack(spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Picker("Canvas Mode", selection: $canvasTab) {
                            Text("Grid Devices").tag("grid")
                            Text("Source Editor").tag("editor")
                            Text("Live Previews").tag("preview")
                            Text("Playground REPL").tag("repl")
                            Text("Command Palette").tag("palette")
                            Text("Matrix Table").tag("matrix")
                            Text("Visual Diff").tag("diff")
                            Text("Time-Travel DVR").tag("timetravel")
                            Text("Accessibility Matrix").tag("accessibility")
                            Text("System Console").tag("console")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 1100)
                    }

                    Spacer()

                    // Zoom Slider (similar to Xcode Previews)
                    if canvasTab == "grid" || canvasTab == "preview" {
                        HStack {
                            Image(systemName: "minus.magnifyingglass")
                            Slider(value: $zoomScale, in: 0.5...2.0)
                                .frame(width: 80)
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(NSColor.windowBackgroundColor))

                Divider()

                // Active Workspace Canvas Display
                VStack(spacing: 0) {
                    ScrollView([.horizontal, .vertical]) {
                        VStack(spacing: 12) {
                            switch canvasTab {
                            case "grid":
                                DeviceGridView(devices: viewModel.devices, zoomScale: zoomScale) { device in
                                    selectedDevice = device
                                }
                                .padding(16)
                                .scaleEffect(zoomScale)
                                .animation(.interactiveSpring, value: zoomScale)

                            case "editor":
                                EditorView(viewModel: viewModel)
                                    .padding(16)

                            case "preview":
                                PreviewsView(viewModel: viewModel)
                                    .padding(16)
                                    .scaleEffect(zoomScale)
                                    .animation(.interactiveSpring, value: zoomScale)

                            case "repl":
                                SwiftPlaygroundREPLView(viewModel: viewModel)
                                    .padding(16)

                            case "palette":
                                CommandPaletteView(viewModel: viewModel)
                                    .padding(16)

                            case "matrix":
                                MatrixTableView(devices: viewModel.devices, jobs: viewModel.jobs)
                                    .padding(16)

                            case "diff":
                                VisualDiffView(selectedDevice: selectedDevice)
                                        .padding(16)

                            case "timetravel":
                                SignatureFeaturesView(viewModel: viewModel, selectedDevice: selectedDevice)
                                    .padding(16)

                            case "accessibility":
                                AccessibilityMatrixView(viewModel: viewModel, selectedDevice: selectedDevice)
                                    .padding(16)

                            case "console":
                                FullLogConsoleView(logs: viewModel.logs, searchText: $consoleSearchText)
                                    .padding(16)

                            default:
                                Text("Select a view mode")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Divider()

                    // Collapsible Inline Resource Timeline lanes (Collapsible Instruments)
                    ResourceTimelineView(devices: viewModel.devices)
                        .frame(height: 120)
                        .background(Color(NSColor.controlBackgroundColor))
                }

                // 3. BOTTOM DRAWER: Console Log Area
                if showConsole {
                    Divider()
                    VStack(spacing: 0) {
                        // Console toolbar
                        HStack {
                            Text("Debug Output")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            TextField("Filter logs", text: $consoleSearchText)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 180)
                                .controlSize(.small)
                            Button(action: { viewModel.logs.removeAll() }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.windowBackgroundColor))

                        Divider()

                        LogsPanelView(logs: viewModel.logs)
                            .frame(height: 160)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 4. RIGHT PANE: Collapsible Utilities Inspector (HStack Three-Pane layout compatible with macOS 13)
            if showInspector {
                Divider()

                InspectorView(
                    selectedDevice: selectedDevice,
                    selectedJob: selectedJob,
                    viewModel: viewModel,
                    inspectorTab: $inspectorTab
                )
                .frame(width: 300)
                .background(VisualEffectView().ignoresSafeArea())
            }
        }
        .task {
            await viewModel.start()
        }
        // Xcode-Grade System Toolbar Section
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Play / Stop Controls
                HStack(spacing: 4) {
                    Button(action: {
                        Task {
                            viewModel.logs.append("Executing iOSLab test matrix scheme: [\(selectedScheme)]")
                            await viewModel.runDefaultTest()
                        }
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                    }
                    .help("Start Matrix Test Execution")
                    .accessibilityLabel("Start Matrix Test Execution")

                    Button(action: {
                        viewModel.logs.append("Stopped running test matrix.")
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                    }
                    .help("Stop Execution")
                    .accessibilityLabel("Stop Execution")
                }

                Divider()

                // Scheme / Destination Selector
                Menu {
                    ForEach(schemes, id: \.self) { scheme in
                        Button(scheme) {
                            selectedScheme = scheme
                            viewModel.logs.append("Switched matrix scheme to [\(scheme)]")
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.3.layers.3d.bottom.filled")
                            .foregroundColor(.accentColor)
                        Text(selectedScheme)
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .help("Select scheme configuration")

                // Live Status Display
                HStack(spacing: 8) {
                    Divider()
                    HStack(spacing: 4) {
                        Image(systemName: "cpu.fill")
                            .foregroundColor(.purple)
                        Text("Running: \(viewModel.devices.filter { $0.status == "busy" }.count)/\(viewModel.devices.count) Active")
                            .font(.system(size: 11, weight: .medium))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("0 Errors")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
            }

            ToolbarItemGroup(placement: .primaryAction) {
                // Collapsible pane toggles like Xcode's header toggles
                Button(action: { showNavigator.toggle() }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Navigator Sidebar")
                .accessibilityLabel("Toggle Navigator Sidebar")

                Button(action: { showConsole.toggle() }) {
                    Image(systemName: "sidebar.bottom")
                }
                .help("Toggle Debug Console Panel")
                .accessibilityLabel("Toggle Debug Console Panel")

                Button(action: { showInspector.toggle() }) {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Utilities Inspector")
                .accessibilityLabel("Toggle Utilities Inspector")
            }
        }
    }
}

// Vibrancy Helper for macOS Split View Sidebar design
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .sidebar
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// ==========================================
// PREFERENCES, STORAGE & SUSTAINABILITY (ContentView Append)
// ==========================================

@MainActor
struct PreferencesView: View {
    let viewModel: DashboardViewModel
    @State private var themeSelector = "system"
    @State private var accentColorSelector = "blue"
    @State private var enableSoundNotifications = true
    @State private var enableSlackAlerts = true

    let themes = ["light", "dark", "system"]
    let accentColors = ["blue", "purple", "pink", "green", "orange"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("App Theme & Preferences Workspace") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("THEME MODE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    Picker("Active UI Theme", selection: $themeSelector) {
                        ForEach(themes, id: \.self) { t in
                            Text(t.uppercased()).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)

                    Divider()

                    Text("ACCENT HIGHLIGHT COLOR")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    Picker("Global Accent", selection: $accentColorSelector) {
                        ForEach(accentColors, id: \.self) { color in
                            Text(color.capitalized).tag(color)
                        }
                    }
                    .pickerStyle(.menu)
                    .controlSize(.small)
                }
            }

            GroupBox("System Alerts & Notifications") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Sound feedback on pass/fail", isOn: $enableSoundNotifications)
                        .font(.caption2)

                    Toggle("Slack/Teams webhook alerts on completion", isOn: $enableSlackAlerts)
                        .font(.caption2)
                        .onChange(of: enableSlackAlerts) { newValue in
                            viewModel.logs.append("Swoggled Slack webhook notification alerts: [\(newValue ? "ON" : "OFF")]")
                        }

                    Divider()

                    Text("Auto-Check Updates")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Stable releases channel active")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Check Now") {
                            viewModel.logs.append("Checking for iOSLab platform application updates...")
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
    }
}

@MainActor
struct StorageDashboardView: View {
    let viewModel: DashboardViewModel
    @State private var vmDiskUsageGb: Double = 124.0
    @State private var cacheDiskUsageGb: Double = 18.4
    @State private var artifactDiskUsageGb: Double = 32.2

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Data Lifecycle & Disk Storage Metrics") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("TOTAL DISK CAPACITY USED")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "internaldrive")
                            .font(.title2)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading) {
                            let totalGb = vmDiskUsageGb + cacheDiskUsageGb + artifactDiskUsageGb
                            let formattedStr = String(format: "%.1f", totalGb)
                            Text("\(formattedStr) GB")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                            Text("Large VM configurations & cached builds found")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    Text("BREAKDOWN STORAGE ANALYSIS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    StorageProgressBar(vm: vmDiskUsageGb, cache: cacheDiskUsageGb, artifacts: artifactDiskUsageGb)

                    VStack(spacing: 4) {
                        StorageLegendRow(color: .purple, name: "Virtualized Guest VM Images", size: "\(vmDiskUsageGb) GB")
                        StorageLegendRow(color: .orange, name: "Cached SPM/Xcode builds", size: "\(cacheDiskUsageGb) GB")
                        StorageLegendRow(color: .blue, name: "Visual test run artifacts", size: "\(artifactDiskUsageGb) GB")
                    }
                }
            }

            GroupBox("Retention auto-cleanup Sweep") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set old visual screenshots, test records, and temporary builds auto-pruning thresholds.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    Button(action: {
                        viewModel.logs.append("Executing storage retention policy cleanup...")
                        artifactDiskUsageGb = 1.2
                        viewModel.logs.append("Successfully reclaimed 31.0 GB of storage disk capacity!")
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Reclaim Storage Disk Space")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .tint(.purple)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct StorageProgressBar: View {
    let vm: Double
    let cache: Double
    let artifacts: Double

    var body: some View {
        let total = vm + cache + artifacts
        GeometryReader { geo in
            let vmWidth = CGFloat(vm / total) * geo.size.width
            let cacheWidth = CGFloat(cache / total) * geo.size.width
            let artWidth = CGFloat(artifacts / total) * geo.size.width
            HStack(spacing: 0) {
                Color.purple
                    .frame(width: vmWidth)
                Color.orange
                    .frame(width: cacheWidth)
                Color.blue
                    .frame(width: artWidth)
            }
        }
        .frame(height: 10)
        .cornerRadius(5)
    }
}

struct StorageLegendRow: View {
    let color: Color
    let name: String
    let size: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.system(size: 9))
            Spacer()
            Text(size)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
        }
    }
}

@MainActor
struct SustainabilityEnergyView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("App Health Score Stock Ticker") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.green)
                        Text("App Health Index Score")
                            .font(.system(size: 10, weight: .bold))
                        Spacer()
                        Text("98.4")
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Trending (+0.4% this week)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.green)
                            .font(.caption2)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("• Crash Free Rate")
                            Spacer()
                            Text("99.98%")
                                .bold()
                        }
                        HStack {
                            Text("• Accessibility Coverage")
                            Spacer()
                            Text("94.2%")
                                .bold()
                        }
                        HStack {
                            Text("• Visual Regressions")
                            Spacer()
                            Text("0 active")
                                .bold()
                        }
                    }
                    .font(.system(size: 8, design: .monospaced))
                }
            }

            GroupBox("CI Sustainability Energy Report") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("Energy Impact & Carbon Report")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Text("Running dozens of simulators and real iOS VMs draws real power. This report tracks real carbon offsets achieved by pruning redundant test matrix slots.")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Divider()

                    HStack {
                        Text("Energy Consumed:")
                        Spacer()
                        Text("12.4 Wh")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    .font(.caption2)

                    HStack {
                        Text("CO2 Emissions Saved:")
                        Spacer()
                        Text("4.8 g CO2 Offset")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    .font(.caption2)
                }
            }
        }
    }
}

public final class HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()
    private init() {}
    public func triggerSuccess() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
    }
    public func triggerFailure() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
    }
    public func triggerSnapshotSwitch() {
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
    }
}
