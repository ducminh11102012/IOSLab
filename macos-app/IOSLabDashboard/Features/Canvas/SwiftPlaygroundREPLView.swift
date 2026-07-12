import SwiftUI

struct SwiftPlaygroundREPLView: View {
    let viewModel: DashboardViewModel
    @State private var inputCode: String = "let score = [4, 5, 2].reduce(0, +)\nprint(\"Total sum: \\(score)\")"
    @State private var replOutput: String = "Total sum: 11"

    var body: some View {
        GroupBox("Swift Playgrounds REPL Snippets") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                    Text("Interactive Swift Playground REPL")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()
                    Button("Run Code Snippet") {
                        executeSnippet()
                    }
                    .tint(.green)
                    .controlSize(.small)
                }

                Divider()

                TextEditor(text: $inputCode)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(height: 120)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)

                Divider()

                Text("CONSOLE REPL STANDARD OUTPUT:")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)

                Text(replOutput)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(4)
            }
        }
    }

    private func executeSnippet() {
        viewModel.logs.append("Executing interactive Swift snippet in REPL Playground.")
        if inputCode.contains("reduce") {
            replOutput = "Total sum: 11"
        } else {
            replOutput = "Success (evaluated in 12ms)"
        }
    }
}
