import SwiftUI

struct VMConsoleView: View {
    let selectedDevice: DeviceModel?
    let viewModel: DashboardViewModel

    @State private var screenshotText: String = "Welcome Screen"
    @State private var backupName: String = ""
    @State private var cpuCores: Double = 4
    @State private var memoryGb: Double = 6
    @State private var diskGb: Double = 64
    @State private var proposedFlows: [String] = []

    var body: some View {
        GroupBox("Virtualized iOS VM Console & Live Session") {
            if let device = selectedDevice, device.type == "vm" {
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 16) {
                        // 1. Live Interactive Viewport (VNC Console)
                        VStack {
                            Text("Interactive Screen Session (Click Viewport)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ZStack {
                                Color.black
                                    .frame(width: 200, height: 400)
                                    .cornerRadius(12)

                                VStack(spacing: 16) {
                                    Image(systemName: "iphone")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 80)
                                        .foregroundColor(.purple)

                                    Text(screenshotText)
                                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)

                                    Text("TAP/CLICK TO MANUAL DEBUG")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.purple)
                                }
                            }
                            .onTapGesture { location in
                                Task {
                                    // Simulate touch input injection
                                    let x = Int(location.x)
                                    let y = Int(location.y)
                                    viewModel.logs.append("Injected console touch at coordinates (\(x), \(y)) on VM \(device.name)")
                                    screenshotText = "Tapped screen at (\(x), \(y))"
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            // 2. Resource Panel (Simulator vs VM Load)
                            GroupBox("Resource Allocator & Load Pressure") {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("VM Load:")
                                        Spacer()
                                        Text("HIGH (4 Cores, 6GB RAM)")
                                            .foregroundColor(.purple)
                                            .bold()
                                    }
                                    .font(.caption)

                                    HStack {
                                        Text("Simulator Load:")
                                        Spacer()
                                        Text("LIGHT (1 Core, 2GB RAM)")
                                            .foregroundColor(.blue)
                                            .bold()
                                    }
                                    .font(.caption)

                                    Divider()

                                    Text("Hot-Swap Core Allocation Configuration")
                                        .font(.system(size: 10, weight: .bold))

                                    HStack {
                                        Text("vCPUs: \(Int(cpuCores))")
                                        Slider(value: $cpuCores, in: 1...16, step: 1)
                                    }
                                    .font(.caption2)

                                    HStack {
                                        Text("RAM: \(Int(memoryGb)) GB")
                                        Slider(value: $memoryGb, in: 2...32, step: 2)
                                    }
                                    .font(.caption2)

                                    Button("Apply VM Configuration") {
                                        viewModel.logs.append("Hot-swapped VM hardware profile to \(Int(cpuCores)) vCPUs, \(Int(memoryGb))GB RAM")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .tint(.purple)
                                }
                            }

                            // 3. Firmware / Backup Manager Panel
                            GroupBox("Firmware & Snapshots Backup Manager") {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Saved VM Backups:")
                                        .font(.caption)
                                        .bold()

                                    ForEach(device.backupList ?? ["Clean Install"], id: \.self) { backup in
                                        HStack {
                                            Text("• \(backup)")
                                                .font(.caption2)
                                            Spacer()
                                            Button("Restore") {
                                                viewModel.logs.append("Restoring VM \(device.name) to backup snapshot [\(backup)]")
                                                screenshotText = "State: \(backup)"
                                            }
                                            .buttonStyle(.borderless)
                                            .font(.system(size: 10))
                                            .foregroundColor(.purple)
                                        }
                                    }

                                    Divider()

                                    HStack {
                                        TextField("Snapshot Name", text: $backupName)
                                            .textFieldStyle(.roundedBorder)
                                        Button("Backup") {
                                            if !backupName.isEmpty {
                                                viewModel.logs.append("Created VM Backup Snapshot: \(backupName)")
                                                backupName = ""
                                            }
                                        }
                                        .tint(.purple)
                                    }
                                }
                            }
                        }
                    }

                    // 4. AI-Assisted Test Proposer
                    GroupBox("AI-Assisted Exploratory Test Generator") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Click below to let iOSLab AI analyze current VM state screen and propose stable automated test specs.")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            HStack {
                                Button("Propose Test Suite Flow") {
                                    proposedFlows = [
                                        "1. Tap Login Button on \(screenshotText)",
                                        "2. Fill in login fields with dummy credentials",
                                        "3. Verify visual layout elements",
                                        "4. Assert transition state"
                                    ]
                                    viewModel.logs.append("AI generated test flow proposals for VM \(device.name)")
                                }
                                .tint(.purple)

                                if !proposedFlows.isEmpty {
                                    Button("Promote to YAML Pipeline") {
                                        viewModel.logs.append("Promoted AI exploratory flows to stable pipeline.yaml suite!")
                                        proposedFlows.removeAll()
                                    }
                                    .tint(.green)
                                }
                            }

                            if !proposedFlows.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Proposed Steps:")
                                        .font(.system(size: 10, weight: .bold))
                                    ForEach(proposedFlows, id: \.self) { flow in
                                        Text(flow)
                                            .font(.system(size: 9, design: .monospaced))
                                    }
                                }
                                .padding(6)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                VStack {
                    Image(systemName: "cpu")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Select any virtualized 'REAL VM' card from the device grid to open the live interactive console session.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
