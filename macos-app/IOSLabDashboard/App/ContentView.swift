import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var runtime: BackendRuntime

    // Layout Navigation Panels
    @State private var selectedDevice: DeviceModel? = nil
    @State private var selectedJob: JobModel? = nil

    // Tab Selections
    @State private var navigatorTab: String = "devices" // devices, tests, reports, snapshots
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
        NavigationSplitView {
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
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
                .background(VisualEffectView().ignoresSafeArea())
            } else {
                Text("Sidebar Collapsed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } detail: {
            // 2. CENTER PANE: Workspace Canvas and Bottom Console Area
            VStack(spacing: 0) {
                // Workspace Header Context Tabs
                HStack(spacing: 16) {
                    Picker("Canvas Mode", selection: $canvasTab) {
                        Text("Grid View").tag("grid")
                        Text("Matrix Table").tag("matrix")
                        Text("Visual Diff").tag("diff")
                        Text("System Console").tag("console")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 360)

                    Spacer()

                    // Zoom Slider (similar to Xcode Previews)
                    if canvasTab == "grid" {
                        HStack {
                            Image(systemName: "minus.magnifyingglass")
                            Slider(value: $zoomScale, in: 0.5...2.0)
                                .frame(width: 100)
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
                GeometryReader { geo in
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

                                case "matrix":
                                    MatrixTableView(devices: viewModel.devices, jobs: viewModel.jobs)
                                        .padding(16)

                                case "diff":
                                    VisualDiffView(selectedDevice: selectedDevice)
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

                        // Collapsible Inline Resource Timeline lanes (Collapsible Instruments)
                        ResourceTimelineView(devices: viewModel.devices)
                            .frame(height: 120)
                            .background(Color(NSColor.controlBackgroundColor))
                    }
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
            // 4. RIGHT PANE: Collapsible Utilities Inspector
            .inspector(isPresented: $showInspector) {
                InspectorView(
                    selectedDevice: selectedDevice,
                    selectedJob: selectedJob,
                    viewModel: viewModel,
                    inspectorTab: $inspectorTab
                )
                .inspectorColumnWidth(min: 260, ideal: 300, max: 340)
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
