import SwiftUI

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
