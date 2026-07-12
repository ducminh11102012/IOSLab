import SwiftUI

struct SignatureFeaturesView: View {
    let viewModel: DashboardViewModel
    let selectedDevice: DeviceModel?

    // Time-Travel DVR variables
    @State private var timeTravelIndex: Double = 3.0
    @State private var framesCount = 4

    // Chaos Monkey variables
    @State private var selectedNetwork = "Wi-Fi"
    @State private var thermalThrottle = false
    @State private var timeOffset: Double = 0.0

    // Device Aging variables
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
                // 1. Time-Travel DVR Scrubbing Timeline
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
                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
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
                    // 2. Mobile Chaos Monkey Engine
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

                    // 3. Device Aging Simulator
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
