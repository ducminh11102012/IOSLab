import SwiftUI

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
