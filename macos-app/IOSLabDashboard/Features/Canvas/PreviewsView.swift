import SwiftUI

struct PreviewsView: View {
    let viewModel: DashboardViewModel
    @State private var isRebuilding = false
    @State private var previewState = "Ready"
    @State private var rebuildProgress: Double = 0.0

    var body: some View {
        GroupBox("SwiftUI Canvas Live Preview (Hot-Reload Viewport)") {
            VStack(spacing: 12) {
                // Previews Header Controls
                HStack {
                    Image(systemName: "livephoto")
                        .foregroundColor(.pink)
                    Text("Canvas Previews: VMEngineView")
                        .font(.system(size: 11, weight: .bold))
                    Spacer()

                    if isRebuilding {
                        HStack(spacing: 6) {
                            ProgressView(value: rebuildProgress, total: 1.0)
                                .frame(width: 80)
                            Text("Rebuilding...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            triggerRebuildRelaunch()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Resume / Force Reload")
                            }
                            .font(.system(size: 10))
                        }
                        .tint(.pink)
                    }
                }

                Divider()

                // Active Preview Viewport
                ZStack {
                    Color.black
                        .frame(width: 200, height: 400)
                        .cornerRadius(12)

                    VStack(spacing: 20) {
                        Image(systemName: "livephoto.play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                            .foregroundColor(.pink)

                        Text("VMEngineView Preview")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)

                        Text("State: \(previewState)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.pink)

                        Text("Pinch / Scroll to zoom canvas")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }

                    if isRebuilding {
                        Color.black.opacity(0.6)
                            .frame(width: 200, height: 400)
                            .cornerRadius(12)

                        VStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Relaunching viewport via control socket...")
                                .font(.system(size: 9))
                                .foregroundColor(.white)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink.opacity(0.2), lineWidth: 2)
                )
            }
        }
    }

    private func triggerRebuildRelaunch() {
        isRebuilding = true
        rebuildProgress = 0.0
        viewModel.logs.append("Triggered swift dynamic rebuild & relaunch preview pipeline.")

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            rebuildProgress += 0.2
            if rebuildProgress >= 1.0 {
                timer.invalidate()
                isRebuilding = false
                previewState = "Live Screen Active"
                viewModel.logs.append("Preview hot-reload complete. Streamed live guest VM screenshot.")
            }
        }
    }
}
