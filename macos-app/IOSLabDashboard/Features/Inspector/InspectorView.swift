import SwiftUI

struct InspectorView: View {
    let selectedDevice: DeviceModel?
    let selectedJob: JobModel?
    let viewModel: DashboardViewModel
    @Binding var inspectorTab: String

    var body: some View {
        VStack(spacing: 0) {
            // Utilities Tab Icon Strip (at top of Inspector Panel)
            HStack(spacing: 16) {
                InspectorTabButton(icon: "info.circle", activeIcon: "info.circle.fill", tag: "attributes", current: $inspectorTab)
                    .help("Attributes Inspector")
                InspectorTabButton(icon: "checklist.checked", activeIcon: "checklist.checked", tag: "test", current: $inspectorTab)
                    .help("Test History Utilities")
                InspectorTabButton(icon: "photo.on.rectangle", activeIcon: "photo.on.rectangle.fill", tag: "diff", current: $inspectorTab)
                    .help("Visual Regression Metrics")
                InspectorTabButton(icon: "play.circle", activeIcon: "play.circle.fill", tag: "actions", current: $inspectorTab)
                    .help("Quick Actions")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Tab Contents
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

                        case "actions":
                            QuickActionsInspectorTab(device: device, viewModel: viewModel)

                        default:
                            Text("No Inspector Tab Selected")
                        }
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

// Single Inspector Tab Button
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

// Tab 1: Attributes Panel
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

// Tab 2: Test History & Sparkline Timeline
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

            // Sparkline showing last five run durations
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

// Tab 3: Visual Diff Metrics
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

// Tab 4: Quick Actions Buttons
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

// Helper Row
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
