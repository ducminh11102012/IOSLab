import SwiftUI

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
