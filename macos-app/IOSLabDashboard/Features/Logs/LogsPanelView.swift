import SwiftUI

struct LogsPanelView: View {
    let logs: [String]

    var body: some View {
        GroupBox("Logs") {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 220)
        }
    }
}
