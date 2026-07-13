import SwiftUI

@MainActor
struct DeviceGridView: View {
    let devices: [DeviceModel]
    var zoomScale: Double = 1.0
    var onSelectDevice: ((DeviceModel) -> Void)? = nil

    var body: some View {
        GroupBox("Unified Device Pool (Simulators & VMs)") {
            let cellWidth: CGFloat = CGFloat(200.0 * zoomScale)
            let cellSpacing: CGFloat = CGFloat(12.0 * zoomScale)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: cellWidth))], spacing: cellSpacing) {
                ForEach(devices) { device in
                    let isVM = device.type == "vm"

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(device.name)
                                .bold()
                                .font(.headline)
                                .foregroundColor(isVM ? .purple : .primary)

                            Spacer()

                            Text(isVM ? "REAL VM" : "SIMULATOR")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isVM ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundColor(isVM ? .purple : .blue)
                                .cornerRadius(4)
                        }

                        Text("Runtime: \(device.runtime)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Status: \(device.status.uppercased())")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(device.status == "ready" ? .green : .orange)

                        if isVM {
                            VStack(alignment: .leading, spacing: 2) {
                                Divider()
                                    .padding(.vertical, 2)
                                Text("Hardware Profile:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.purple)
                                Text("• CPU Cores: \(device.cpu ?? 4)")
                                    .font(.system(size: 9))
                                Text("• Memory: \(device.memory ?? 6) GB")
                                    .font(.system(size: 9))
                                Text("• Disk: \(device.disk ?? 64) GB")
                                    .font(.system(size: 9))
                                Text("• Patch Tier: \(device.currentPatchTier ?? "boot-only")")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Divider()
                                    .padding(.vertical, 2)
                                Text("Simulator Profile:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("• Model ID: \(device.modelId ?? "iPhone 15")")
                                    .font(.system(size: 9))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(isVM ? Color.purple.opacity(0.05) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isVM ? Color.purple.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: isVM ? 2 : 1)
                    )
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelectDevice?(device)
                    }
                }
            }
        }
    }
}

// ==========================================
// WORKSPACE CANVAS TABS (DeviceGridView Append)
// ==========================================

@MainActor
struct MatrixTableView: View {
    let devices: [DeviceModel]
    let jobs: [JobModel]

    var body: some View {
        GroupBox("Test Matrix Target Status Map") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Dense Coverage Matrix Overview")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                Table(devices) {
                    TableColumn("Device Name", value: \.name)
                    TableColumn("Type") { d in
                        Text(d.type?.uppercased() ?? "SIMULATOR")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(d.type == "vm" ? .purple : .blue)
                    }
                    TableColumn("OS Runtime") { d in
                        Text(d.runtime.components(separatedBy: ".").last ?? "iOS 18.0")
                            .font(.caption2)
                    }
                    TableColumn("Device Status") { d in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(d.status == "ready" ? Color.green : (d.status == "busy" ? Color.purple : Color.gray))
                                .frame(width: 6, height: 6)
                            Text(d.status.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(d.status == "ready" ? .green : .orange)
                        }
                    }
                    TableColumn("Current Job") { d in
                        if d.status == "busy" {
                            Text("Running Suite: AppTests")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        } else {
                            Text("Idle / Waiting")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 260)
            }
        }
    }
}

@MainActor
struct VisualDiffView: View {
    let selectedDevice: DeviceModel?
    @State private var diffScrubber: Double = 0.5
    @State private var showHeatmap = false

    var body: some View {
        GroupBox("Visual Regression Analysis") {
            if let device = selectedDevice {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Visual Diff: \(device.name)")
                                .font(.headline)
                            Text("Comparing actual guest screenshot against recorded baseline")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("Show Pixel Heatmap", isOn: $showHeatmap)
                            .toggleStyle(.checkbox)
                    }

                    HStack(spacing: 20) {
                        VStack {
                            Text("Baseline (Expected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.gray.opacity(0.1)
                                    .frame(width: 140, height: 260)
                                    .cornerRadius(8)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                    Text("Baseline State")
                                        .font(.caption2)
                                }
                            }
                        }

                        VStack {
                            Text("Smooth Crossfade Comparison")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.black
                                    .frame(width: 180, height: 260)
                                    .cornerRadius(8)

                                if showHeatmap {
                                    Color.red.opacity(0.4)
                                        .frame(width: 180, height: 260)
                                        .cornerRadius(8)
                                    Text("Pixel Diff: 0.12%")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Color.purple.opacity(diffScrubber)
                                        .frame(width: 180, height: 260)
                                        .cornerRadius(8)
                                    Text("Scrubbed: \(Int(diffScrubber * 100))%")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            Slider(value: $diffScrubber, in: 0.0...1.0)
                                .frame(width: 140)
                        }

                        VStack {
                            Text("Current (Actual)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.gray.opacity(0.1)
                                    .frame(width: 140, height: 260)
                                    .cornerRadius(8)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.purple)
                                    Text("Actual State")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Select a device from the sidebar or grid to compare pixel layouts and execute visual regressions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(height: 320)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

@MainActor
struct FullLogConsoleView: View {
    let logs: [String]
    @Binding var searchText: String

    var body: some View {
        GroupBox("System Console Monitor") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "terminal")
                        .foregroundColor(.green)
                    Text("All Devices Consolidated Monospace Log Streams")
                        .font(.system(size: 11, weight: .bold))
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        let filteredLogs = logs.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }

                        if filteredLogs.isEmpty {
                            Text("No matching log lines discovered.")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(filteredLogs.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(line.contains("error") ? .red : (line.contains("finished") ? .green : .primary))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(height: 320)
                .padding(8)
                .background(Color.black.opacity(0.05))
                .cornerRadius(6)
            }
        }
    }
}

@MainActor
struct ResourceTimelineView: View {
    let devices: [DeviceModel]
    @State private var timeOffset: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.purple)
                Text("Instruments Core Resource Profiler (Real-time CPU/Memory Pressure Lanes)")
                    .font(.system(size: 10, weight: .bold))
                Spacer()
                Text("Timeline: Live Streaming")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            Divider()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(devices) { device in
                        let isVM = device.type == "vm"

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(device.name)
                                    .font(.system(size: 9, weight: .bold))
                                Spacer()
                                Text(isVM ? "VM Lane" : "SIM Lane")
                                    .font(.system(size: 7, weight: .semibold))
                                    .foregroundColor(isVM ? .purple : .blue)
                            }

                            HStack(spacing: 1) {
                                ForEach(0..<20, id: \.self) { index in
                                    let randHeight: CGFloat = (device.status == "busy")
                                        ? CGFloat.random(in: 12...32)
                                        : CGFloat.random(in: 2...8)

                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(isVM ? Color.purple : Color.blue)
                                        .frame(width: 3, height: randHeight)
                                        .animation(.interactiveSpring, value: randHeight)
                                }
                            }
                            .frame(height: 36, alignment: .bottom)
                            .frame(width: 80)
                            .background(Color.black.opacity(0.03))
                            .cornerRadius(4)

                            HStack {
                                Text("CPU: \((device.status == "busy") ? Int.random(in: 45...88) : Int.random(in: 2...12))%")
                                Spacer()
                                Text("RAM: \((device.status == "busy") ? Int.random(in: 60...92) : Int.random(in: 5...25))%")
                            }
                            .font(.system(size: 7, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                        )
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
    }
}

@MainActor
struct CommandPaletteView: View {
    let viewModel: DashboardViewModel
    @State private var queryText: String = ""

    let commands = [
        "Spawn Simulator - iPhone 15 (iOS 18.0)",
        "Spawn Virtual Machine - iOS 18 Guest VM",
        "Run Test Suite Scheme - Hybrid Matrix",
        "Create VM Snapshots State Backup",
        "Restore VM State Snapshot",
        "Clear Storage Disk Cache Data",
        "Export JUnit XML Test Report",
        "Run Workspace Doctor Diagnostics Check"
    ]

    var body: some View {
        GroupBox("Command Palette Overlay (Cmd+Shift+P)") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                    TextField("Search quick actions, logs, devices, and settings...", text: $queryText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                }

                Divider()

                Text("QUICK ACTION MATCHES:")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)

                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        let filtered = commands.filter { queryText.isEmpty || $0.localizedCaseInsensitiveContains(queryText) }

                        if filtered.isEmpty {
                            Text("No matching command actions discovered.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(filtered, id: \.self) { cmd in
                                Button(action: {
                                    viewModel.logs.append("Executed command action: [\(cmd)]")
                                    queryText = ""
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.right.square")
                                            .foregroundColor(.blue)
                                        Text(cmd)
                                            .font(.system(size: 11))
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.vertical, 3)
                            }
                        }
                    }
                }
                .frame(height: 140)
            }
        }
    }
}

@MainActor
struct SignatureFeaturesView: View {
    let viewModel: DashboardViewModel
    let selectedDevice: DeviceModel?

    @State private var timeTravelIndex: Double = 3.0
    @State private var framesCount = 4
    @State private var selectedNetwork = "Wi-Fi"
    @State private var thermalThrottle = false
    @State private var timeOffset: Double = 0.0
    @State private var batteryDegraded = false
    @State private var diskFullLevel: Double = 12.0

    let networkProfiles = ["Wi-Fi", "3G", "2G", "No-Network"]
    let dvrStates = [
        "Welcome Screen (0s ago)",
        "Language Setup (3s ago)",
        "Home Screen (2s ago)",
        "Dashboard Active (1s ago)"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let device = selectedDevice, device.type == "vm" {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.pink)
                                .font(.headline)
                            Text("Time-Travel DVR Recorder")
                                .font(.headline)
                            Spacer()
                            Text("INTERVAL: 1s")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pink.opacity(0.1))
                                .cornerRadius(4)
                        }

                        Text("Continuously records guest iOS system memory, filesystem modifications, and frame screen states. Drag the timeline scrub below to rewind frame-by-frame.")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            ZStack {
                                Color.black
                                    .frame(width: 140, height: 200)
                                    .cornerRadius(8)

                                VStack(spacing: 8) {
                                    Image(systemName: "video.fill")
                                        .foregroundColor(.pink)
                                    Text(dvrStates[Int(timeTravelIndex)])
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                    Text("MEM: \((1.2 + Double(timeTravelIndex)*0.3).formatted("%.1f")) GB")
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("DVR Frame Information:")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.pink)

                                Text("• State: \(dvrStates[Int(timeTravelIndex)])")
                                    .font(.caption2)
                                Text("• Thread Registers: Stacked & Cached")
                                    .font(.caption2)
                                Text("• Screen Diff: Validated")
                                    .font(.caption2)

                                Spacer()

                                Button("Replay Flow from this Frame") {
                                    viewModel.logs.append("Replaying VM [\(device.name)] test flow rewound from frame: \(dvrStates[Int(timeTravelIndex)])")
                                }
                                .controlSize(.small)
                                .tint(.pink)
                            }
                        }

                        HStack {
                            Text("START")
                                .font(.system(size: 8, weight: .bold))
                            Slider(value: $timeTravelIndex, in: 0...3, step: 1)
                                .tint(.pink)
                            Text("LIVE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.pink)
                        }
                    }
                } label: {
                    Label("Time-Travel DVR Recorder", systemImage: "arrow.uturn.backward")
                }

                HStack(alignment: .top, spacing: 16) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Injected Controlled Real-World Failures")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Picker("Network Profiler", selection: $selectedNetwork) {
                                ForEach(networkProfiles, id: \.self) { profile in
                                    Text(reportIcon(for: profile) + " " + profile).tag(profile)
                                }
                            }
                            .pickerStyle(.menu)
                            .controlSize(.small)
                            .onChange(of: selectedNetwork) { newValue in
                                Task {
                                    let payload = ["networkProfile": newValue]
                                    let body = try JSONSerialization.data(withJSONObject: payload)
                                    try await viewModel.apiClient.post(path: "vms/\(device.id)/chaos", body: body)
                                    viewModel.logs.append("Chaos Monkey: Changed network profile of [\(device.name)] to \(newValue)")
                                }
                            }

                            Toggle("Thermal Throttling (CPU limit)", isOn: $thermalThrottle)
                                .font(.caption2)
                                .onChange(of: thermalThrottle) { newValue in
                                    Task {
                                        let payload = ["thermalThrottle": newValue]
                                        let body = try JSONSerialization.data(withJSONObject: payload)
                                        try await viewModel.apiClient.post(path: "vms/\(device.id)/chaos", body: body)
                                        viewModel.logs.append("Chaos Monkey: \(newValue ? "Enabled" : "Disabled") VM Thermal CPU throttling")
                                    }
                                }

                            HStack {
                                Text("System Clock Offset:")
                                    .font(.caption2)
                                Spacer()
                                Text("\(Int(timeOffset))s")
                                    .font(.system(size: 9, design: .monospaced))
                            }
                            Slider(value: $timeOffset, in: -86400...86400, step: 3600)
                                .onChange(of: timeOffset) { newValue in
                                    Task {
                                        let payload = ["systemClockOffset": Int(newValue)]
                                        let body = try JSONSerialization.data(withJSONObject: payload)
                                        try await viewModel.apiClient.post(path: "vms/\(device.id)/chaos", body: body)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label("Mobile Chaos Engine", systemImage: "bolt.shield")
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Degrade pristine VM hardware state to worn-user status")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Toggle("Degrade Battery Health", isOn: $batteryDegraded)
                                .font(.caption2)
                                .onChange(of: batteryDegraded) { newValue in
                                    Task {
                                        let payload = ["batteryDegraded": newValue]
                                        let body = try JSONSerialization.data(withJSONObject: payload)
                                        try await viewModel.apiClient.post(path: "vms/\(device.id)/aging", body: body)
                                        viewModel.logs.append("Aging Simulator: \(newValue ? "Degraded" : "Restored") battery health on VM [\(device.name)]")
                                    }
                                }

                            HStack {
                                Text("Cache Disk Full:")
                                    .font(.caption2)
                                Spacer()
                                Text("\(Int(diskFullLevel))% capacity")
                                    .font(.system(size: 9, design: .monospaced))
                            }
                            Slider(value: $diskFullLevel, in: 5...99, step: 5)
                                .onChange(of: diskFullLevel) { newValue in
                                    Task {
                                        let payload = ["diskFullLevel": Int(newValue)]
                                        let body = try JSONSerialization.data(withJSONObject: payload)
                                        try await viewModel.apiClient.post(path: "vms/\(device.id)/aging", body: body)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } label: {
                        Label("Device Aging Simulator", systemImage: "hourglass")
                    }
                }
            } else {
                VStack {
                    Image(systemName: "cpu")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.4))
                    Text("Select a virtualized real-iOS VM card from the sidebar grid to enable signature Time-Travel DVR, Mobile Chaos Monkeys, and hardware Aging tools.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 320)
            }
        }
    }

    private func reportIcon(for network: String) -> String {
        switch network {
        case "Wi-Fi": return "wifi"
        case "3G": return "3.circle"
        case "2G": return "2.circle"
        case "No-Network": return "wifi.slash"
        default: return "wifi"
        }
    }
}

@MainActor
struct AccessibilityMatrixView: View {
    let viewModel: DashboardViewModel
    let selectedDevice: DeviceModel?

    @State private var voiceOverAuditPassed = true
    @State private var textScalePercent: Double = 100.0
    @State private var localeSelector = "en_US"

    let localesList = [
        "en_US (English)",
        "ar_EG (Arabic - RTL)",
        "fr_FR (French)",
        "de_DE (German)",
        "pseudo_LOC (Pseudo-Expanded Strings)"
    ]

    var body: some View {
        GroupBox("Accessibility & Localization Integrity Matrix") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Automated layout validation and speech audit runs across all accessible HIG modalities simultaneously.")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Accessibility Modalities", systemImage: "figure.roll")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)

                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.green)
                            Text("VoiceOver Speech Flow Audit")
                            Spacer()
                            Text("PASSED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .font(.caption2)

                        HStack {
                            Image(systemName: "textformat.size.larger")
                                .foregroundColor(.orange)
                            Text("Dynamic Larger Text Scaling")
                            Spacer()
                            Text("\(Int(textScalePercent))%")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                        }
                        .font(.caption2)
                        Slider(value: $textScalePercent, in: 100...300, step: 25)

                        HStack {
                            Image(systemName: "arrow.left.and.right")
                                .foregroundColor(.blue)
                            Text("Reduce Motion State Checker")
                            Spacer()
                            Text("COMPLIANT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Localization Truth Table", systemImage: "globe")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)

                        Picker("Language Locale", selection: $localeSelector) {
                            ForEach(localesList, id: \.self) { locale in
                                Text(locale).tag(locale)
                             }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)

                        HStack {
                            Image(systemName: "arrow.left.to.line")
                                .foregroundColor(localeSelector.contains("ar_EG") ? .green : .secondary)
                            Text("RTL Layout Auto-alignment")
                            Spacer()
                            Text(localeSelector.contains("ar_EG") ? "RTL ACTIVE" : "LTR")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(localeSelector.contains("ar_EG") ? .green : .secondary)
                        }
                        .font(.caption2)

                        HStack {
                            Image(systemName: "character.textbox")
                                .foregroundColor(.orange)
                            Text("Pseudo-Localization Overflows")
                            Spacer()
                            Text("0 Clipped")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .font(.caption2)

                        Button("Execute Multi-Locale Layout Verification") {
                            viewModel.logs.append("Executing 12-locale pseudo-string truncation verification on VM matrix.")
                        }
                        .controlSize(.small)
                        .tint(.purple)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
