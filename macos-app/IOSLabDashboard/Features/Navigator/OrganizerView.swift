import SwiftUI

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
            // 1. Crash Log Symbolicator
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

            // 2. TestFlight builds list
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
