import SwiftUI

struct TestTimelineView: View {
    let jobs: [JobModel]

    var body: some View {
        GroupBox("Test Timeline") {
            List(jobs) { job in
                HStack {
                    Text(job.testTarget)
                    Spacer()
                    Text(job.status).foregroundColor(.secondary)
                }
            }
            .frame(height: 160)
        }
    }
}

// ==========================================
// MULTI-TABBED NAVIGATORS (TestTimelineView Append)
// ==========================================

struct NavigatorView: View {
    @Binding var navigatorTab: String // devices, tests, reports, snapshots, project, git, packages, organizer, booking, automation
    let devices: [DeviceModel]
    let jobs: [JobModel]

    @Binding var selectedDevice: DeviceModel?
    @Binding var selectedJob: JobModel?

    let viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Tab Icon Strip (representing Xcode's multi-tabbed Navigator header)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NavigatorTabButton(icon: "folder", activeIcon: "folder.fill", tag: "project", current: $navigatorTab)
                        .help("Project Navigator (.xcodeproj / SPM)")
                    NavigatorTabButton(icon: "iphone.circle", activeIcon: "iphone.circle.fill", tag: "devices", current: $navigatorTab)
                        .help("Device & VM Navigator")
                    NavigatorTabButton(icon: "checkmark.circle", activeIcon: "checkmark.circle.fill", tag: "tests", current: $navigatorTab)
                        .help("Test Navigator")
                    NavigatorTabButton(icon: "doc.plaintext", activeIcon: "doc.plaintext.fill", tag: "reports", current: $navigatorTab)
                        .help("Report Navigator")
                    NavigatorTabButton(icon: "clock.arrow.2.circlepath", activeIcon: "clock.arrow.2.circlepath", tag: "snapshots", current: $navigatorTab)
                        .help("Snapshot Navigator")
                    NavigatorTabButton(icon: "arrow.triangle.branch", activeIcon: "arrow.triangle.branch", tag: "git", current: $navigatorTab)
                        .help("Source Control Navigator")
                    NavigatorTabButton(icon: "shippingbox", activeIcon: "shippingbox.fill", tag: "packages", current: $navigatorTab)
                        .help("SPM Packages Navigator")
                    NavigatorTabButton(icon: "archivebox", activeIcon: "archivebox.fill", tag: "organizer", current: $navigatorTab)
                        .help("Organizer (Crashes, TestFlight)")
                    NavigatorTabButton(icon: "calendar.badge.clock", activeIcon: "calendar.badge.clock", tag: "booking", current: $navigatorTab)
                        .help("Security Audits & Booking Slots")
                    NavigatorTabButton(icon: "link", activeIcon: "link", tag: "automation", current: $navigatorTab)
                        .help("CI/CD Integrations & Webhooks")
                }
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Sidebar lists
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch navigatorTab {
                    case "project":
                        ProjectNavigatorList(viewModel: viewModel)

                    case "devices":
                        DeviceNavigatorList(devices: devices, selectedDevice: $selectedDevice)

                    case "tests":
                        TestNavigatorList(jobs: jobs, selectedJob: $selectedJob)

                    case "reports":
                        ReportNavigatorList(viewModel: viewModel)

                    case "snapshots":
                        SnapshotNavigatorList(devices: devices, viewModel: viewModel)

                    case "git":
                        GitNavigatorList(viewModel: viewModel)

                    case "packages":
                        SPMPackagesList(viewModel: viewModel)

                    case "organizer":
                        OrganizerView(viewModel: viewModel)

                    case "booking":
                        AuditBookingView(viewModel: viewModel)

                    case "automation":
                        AutomationIntegrationsView(viewModel: viewModel)

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
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(current == tag ? .accentColor : .secondary)
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
    }
}

struct ProjectNavigatorList: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PROJECT FILES TREE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            DisclosureGroup(isExpanded: .constant(true)) {
                VStack(alignment: .leading, spacing: 6) {
                    FileRowView(name: "Package.swift", icon: "doc.text", color: .purple) {
                        viewModel.logs.append("Opened Package.swift config in editor.")
                    }

                    DisclosureGroup(isExpanded: .constant(true)) {
                        FileRowView(name: "OrchestratorService.swift", icon: "doc.text.fill", color: .orange) {
                            viewModel.logs.append("Opened OrchestratorService.swift in editor.")
                        }
                        FileRowView(name: "VMEngine.swift", icon: "doc.text.fill", color: .orange) {
                            viewModel.logs.append("Opened VMEngine.swift in editor.")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                                .font(.system(size: 11))
                                .foregroundColor(.accentColor)
                            Text("Sources")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }

                    DisclosureGroup(isExpanded: .constant(true)) {
                        FileRowView(name: "AppTests.swift", icon: "doc.text.fill", color: .orange) {
                            viewModel.logs.append("Opened AppTests.swift in editor.")
                        }
                        FileRowView(name: "VMIntegrationTests.swift", icon: "doc.text.fill", color: .orange) {
                            viewModel.logs.append("Opened VMIntegrationTests.swift in editor.")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                                .font(.system(size: 11))
                                .foregroundColor(.accentColor)
                            Text("Tests")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                }
                .padding(.leading, 8)
            } label: {
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                    Text("iOSLabWorkspace")
                        .font(.system(size: 11, weight: .bold))
                }
            }
        }
    }
}

struct FileRowView: View {
    let name: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(name)
                .font(.system(size: 11))
            Spacer()
        }
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

struct DeviceNavigatorList: View {
    let devices: [DeviceModel]
    @Binding var selectedDevice: DeviceModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DEVICES & VIRTUAL MACHINES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            let runtimes = Array(Set(devices.map { $0.runtime })).sorted()

            ForEach(runtimes, id: \.self) { runtime in
                let runtimeDevices = devices.filter { $0.runtime == runtime }
                let osVersion = runtime.components(separatedBy: ".").last?.replacingOccurrences(of: "iOS-", with: "iOS ") ?? "iOS 18.0"

                DisclosureGroup(isExpanded: .constant(true)) {
                    ForEach(runtimeDevices) { device in
                        HStack(spacing: 6) {
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

struct GitNavigatorList: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SOURCE CONTROL (GIT STATUS)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            DisclosureGroup(isExpanded: .constant(true)) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text("main (tracking origin/main)")
                            .font(.system(size: 11, design: .monospaced))
                        Spacer()
                    }
                    .padding(.leading, 8)

                    Divider()

                    Text("LOCAL CHANGED FILES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    FileRowView(name: "VMEngine.swift (M)", icon: "pencil.circle.fill", color: .orange) {
                        viewModel.logs.append("Diffing VMEngine.swift changes in Git editor.")
                    }
                    FileRowView(name: "Package.swift (M)", icon: "pencil.circle.fill", color: .purple) {
                        viewModel.logs.append("Diffing Package.swift changes in Git editor.")
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                    Text("ioslab-workspace")
                        .font(.system(size: 11, weight: .bold))
                }
            }
        }
    }
}

struct SPMPackagesList: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SWIFT PACKAGES DEPENDENCIES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            DisclosureGroup(isExpanded: .constant(true)) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("FastifyEngine (v2.4.0)")
                            .font(.system(size: 11))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 11))
                            .foregroundColor(.blue)
                        Text("SwiftLSP-Client (v0.8.1)")
                            .font(.system(size: 11))
                        Spacer()
                    }
                }
                .padding(.leading, 8)
            } label: {
                HStack {
                    Image(systemName: "cube.box")
                        .font(.system(size: 11))
                        .foregroundColor(.purple)
                    Text("SPM Package Dependencies")
                        .font(.system(size: 11, weight: .bold))
                }
            }
        }
    }
}

struct OrganizerView: View {
    let viewModel: DashboardViewModel

    let crashLogs = [
        "Thread 0 Crashed: EXC_BAD_ACCESS in VMEngine.swift:12",
        "Thread 2 Crashed: Out of Memory in SimRuntime (iPhone 15)"
    ]

    let testFlightBuilds = [
        "v2.1.0 (Build 124) - App Store Processing",
        "v2.0.4 (Build 123) - TestFlight Live Testing"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Crash Symbolicator Logs Organizer") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "ladybug.fill")
                            .foregroundColor(.red)
                        Text("Unsymbolicated Crashes Found")
                            .font(.system(size: 10, weight: .bold))
                    }

                    ForEach(crashLogs, id: \.self) { log in
                        HStack {
                            Text(log)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.red)
                                .lineLimit(1)
                            Spacer()
                            Button("Symbolicate") {
                                viewModel.logs.append("Symbolicated crash log via atos command: [\(log)]")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                        }
                    }
                }
            }

            GroupBox("TestFlight App Store Connect Organizer") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "paperplane.circle.fill")
                            .foregroundColor(.blue)
                        Text("Active TestFlight Build Releases")
                            .font(.system(size: 10, weight: .bold))
                    }

                    ForEach(testFlightBuilds, id: \.self) { build in
                        HStack {
                            Text(build)
                                .font(.system(size: 9))
                            Spacer()
                        }
                    }

                    Button("Upload Build Archive...") {
                        viewModel.logs.append("Shelling out to xcodebuild -exportArchive / xcrun altool to upload IPA.")
                    }
                    .controlSize(.small)
                    .tint(.blue)
                }
            }
        }
    }
}

struct AuditBookingView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Security Audit Logs (Access Control)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PLATFORM WORKSPACE AUDITING")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        AuditRow(time: "10:14:12", user: "admin", action: "Provisioned real guest VM")
                        AuditRow(time: "10:11:05", user: "dev_alice", action: "Approved layout baseline change")
                        AuditRow(time: "09:58:32", user: "system", action: "Executed nightly cron-sweep")
                    }
                }
            }

            GroupBox("Device Pool Reservations & Booking") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("discover and lock guest VM and simulator slots on shared Mac infrastructure.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.purple)
                        Text("Current Slot Booking:")
                            .font(.system(size: 10, weight: .bold))
                        Spacer()
                        Text("Available")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }

                    Button("Book Pool Slot for 1 hour") {
                        viewModel.logs.append("Reserved local hypervisor device pool slot for 60 minutes.")
                    }
                    .controlSize(.small)
                    .tint(.purple)
                }
            }
        }
    }
}

struct AuditRow: View {
    let time: String
    let user: String
    let action: String

    var body: some View {
        HStack(spacing: 6) {
            Text(time)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.secondary)
            Text("[\(user)]")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.purple)
            Text(action)
                .font(.system(size: 9))
                .lineLimit(1)
            Spacer()
        }
    }
}

struct AutomationIntegrationsView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("CI/CD Integrations & Fastlane plugins") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("AUTOMATION CONFIGURATOR")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "circle.grid.cross.fill")
                            .foregroundColor(.blue)
                        Text("Copy Fastlane plugin code")
                            .font(.system(size: 11))
                        Spacer()
                        Button("Copy") {
                            viewModel.logs.append("Copied Fastlane plugin configuration script to pasteboard.")
                        }
                        .controlSize(.small)
                    }

                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.purple)
                        Text("Copy GitHub Actions YAML")
                            .font(.system(size: 11))
                        Spacer()
                        Button("Copy") {
                            viewModel.logs.append("Copied GitHub Actions workflow YAML block to pasteboard.")
                        }
                        .controlSize(.small)
                    }
                }
            }

            GroupBox("Result Exports & Integrations") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export test matrix runs in standard schemas for downstream CI reporters.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Export JUnit XML Report") {
                            viewModel.logs.append("Generated JUnit XML test result report.")
                        }
                        .controlSize(.small)

                        Button("Export LCOV Coverage") {
                            viewModel.logs.append("Generated standard LCOV code coverage bundle.")
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
    }
}
