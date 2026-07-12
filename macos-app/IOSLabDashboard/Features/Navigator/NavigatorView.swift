import SwiftUI

struct NavigatorView: View {
    @Binding var navigatorTab: String
    let devices: [DeviceModel]
    let jobs: [JobModel]

    @Binding var selectedDevice: DeviceModel?
    @Binding var selectedJob: JobModel?

    let viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Icon Tab Strip (like top of Xcode Navigator)
            HStack(spacing: 16) {
                NavigatorTabButton(icon: "iphone.circle", activeIcon: "iphone.circle.fill", tag: "devices", current: $navigatorTab)
                    .help("Device Navigator")
                NavigatorTabButton(icon: "checkmark.circle", activeIcon: "checkmark.circle.fill", tag: "tests", current: $navigatorTab)
                    .help("Test Navigator")
                NavigatorTabButton(icon: "doc.plaintext", activeIcon: "doc.plaintext.fill", tag: "reports", current: $navigatorTab)
                    .help("Report Navigator")
                NavigatorTabButton(icon: "clock.arrow.2.circlepath", activeIcon: "clock.arrow.2.circlepath", tag: "snapshots", current: $navigatorTab)
                    .help("Snapshot Navigator")
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Sidebar Lists based on selected tab
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch navigatorTab {
                    case "devices":
                        DeviceNavigatorList(devices: devices, selectedDevice: $selectedDevice)

                    case "tests":
                        TestNavigatorList(jobs: jobs, selectedJob: $selectedJob)

                    case "reports":
                        ReportNavigatorList(viewModel: viewModel)

                    case "snapshots":
                        SnapshotNavigatorList(devices: devices, viewModel: viewModel)

                    default:
                        Text("No Navigator Tab Selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Single Icon Tab Button
struct NavigatorTabButton: View {
    let icon: String
    let activeIcon: String
    let tag: String
    @Binding var current: String

    var body: some View {
        Button(action: {
            current = tag
        }) {
            Image(systemName: current == tag ? activeIcon : icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(current == tag ? .accentColor : .secondary)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
    }
}

// 1. Device Navigator Tree View
struct DeviceNavigatorList: View {
    let devices: [DeviceModel]
    @Binding var selectedDevice: DeviceModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEVICES & VIRTUAL MACHINES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            // Grouped by iOS version / runtime
            let runtimes = Array(Set(devices.map { $0.runtime })).sorted()

            ForEach(runtimes, id: \.self) { runtime in
                let runtimeDevices = devices.filter { $0.runtime == runtime }
                let osVersion = runtime.components(separatedBy: ".").last?.replacingOccurrences(of: "iOS-", with: "iOS ") ?? "iOS 18.0"

                DisclosureGroup(isExpanded: .constant(true)) {
                    ForEach(runtimeDevices) { device in
                        HStack(spacing: 6) {
                            // Status Dot Indicator
                            Circle()
                                .fill(device.status == "ready" ? Color.green : (device.status == "busy" ? Color.purple : Color.gray))
                                .frame(width: 6, height: 6)

                            Image(systemName: device.type == "vm" ? "cpu" : "iphone")
                                .font(.caption2)
                                .foregroundColor(device.type == "vm" ? .purple : .blue)

                            Text(device.name)
                                .font(.system(size: 12))
                                .foregroundColor(selectedDevice?.id == device.id ? .accentColor : .primary)

                            Spacer()
                        }
                        .padding(.leading, 8)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDevice = device
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "folder")
                            .font(.system(size: 11))
                            .foregroundColor(.accentColor)
                        Text(osVersion)
                            .font(.system(size: 11, weight: .bold))
                    }
                }
            }
        }
    }
}

// 2. Test Navigator Tree (Suite -> Device -> Case)
struct TestNavigatorList: View {
    let jobs: [JobModel]
    @Binding var selectedJob: JobModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TEST MATRIX WORKSPACES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            if jobs.isEmpty {
                Text("No active test targets.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                DisclosureGroup(isExpanded: .constant(true)) {
                    ForEach(jobs) { job in
                        HStack(spacing: 6) {
                            Image(systemName: job.status == "completed" ? "checkmark.circle.fill" : (job.status == "failed" ? "xmark.circle.fill" : "clock"))
                                .font(.system(size: 10))
                                .foregroundColor(job.status == "completed" ? .green : (job.status == "failed" ? .red : .orange))

                            Text(job.testTarget)
                                .font(.system(size: 12))
                                .foregroundColor(selectedJob?.id == job.id ? .accentColor : .primary)

                            Spacer()
                        }
                        .padding(.leading, 8)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedJob = job
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "checklist")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("AppTests Matrix")
                            .font(.system(size: 11, weight: .bold))
                    }
                }
            }
        }
    }
}

// 3. Report Navigator History
struct ReportNavigatorList: View {
    let viewModel: DashboardViewModel

    let reports = [
        "Matrix Run #44 - Completed (iOS 18)",
        "Matrix Run #43 - 2 Failures (iOS 17)",
        "Matrix Run #42 - Completed (iOS 18)",
        "Matrix Run #41 - Completed (iOS 15)"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EXECUTION REPORTS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            ForEach(reports, id: \.self) { report in
                HStack(spacing: 6) {
                    Image(systemName: report.contains("Fail") ? "xmark.square.fill" : "checkmark.square.fill")
                        .font(.caption2)
                        .foregroundColor(report.contains("Fail") ? .red : .green)

                    Text(report)
                        .font(.system(size: 11))
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.vertical, 3)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.logs.append("Opened historical execution log: [\(report)]")
                }
            }
        }
    }
}

// 4. Snapshot / Backup Navigator Branch List
struct SnapshotNavigatorList: View {
    let devices: [DeviceModel]
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VIRTUAL MACHINE SNAPSHOTS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            let vms = devices.filter { $0.type == "vm" }
            if vms.isEmpty {
                Text("No active VMs discovered.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(vms) { vm in
                    DisclosureGroup(isExpanded: .constant(true)) {
                        ForEach(vm.backupList ?? ["Clean Install"], id: \.self) { backup in
                            HStack {
                                Image(systemName: "point.3.connected.trianglepath.dotted")
                                    .font(.system(size: 9))
                                    .foregroundColor(.purple)
                                Text(backup)
                                    .font(.system(size: 11, design: .monospaced))
                                Spacer()
                                Button(action: {
                                    viewModel.logs.append("Hot-swapped VM [\(vm.name)] to backup snapshot [\(backup)]")
                                }) {
                                    Text("Switch")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple)
                                        .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.leading, 8)
                            .padding(.vertical, 3)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.system(size: 11))
                                .foregroundColor(.purple)
                            Text(vm.name)
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
            }
        }
    }
}
