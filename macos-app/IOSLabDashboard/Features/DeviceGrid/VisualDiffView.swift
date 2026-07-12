import SwiftUI

struct VisualDiffView: View {
    let selectedDevice: DeviceModel?
    @State private var diffScrubber: Double = 0.5
    @State private var showHeatmap = false

    var body: some View {
        GroupBox("Visual Regression Analysis") {
            if let device = selectedDevice {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Visual Diff: \(device.name)")
                                .font(.headline)
                            Text("Comparing actual guest screenshot against recorded baseline")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("Show Pixel Heatmap", isOn: $showHeatmap)
                            .toggleStyle(.checkbox)
                    }

                    HStack(spacing: 20) {
                        // Left: Baseline
                        VStack {
                            Text("Baseline (Expected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.gray.opacity(0.1)
                                    .frame(width: 140, height: 260)
                                    .cornerRadius(8)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                    Text("Baseline State")
                                        .font(.caption2)
                                }
                            }
                        }

                        // Center: Scrubber Comparison
                        VStack {
                            Text("Smooth Crossfade Comparison")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.black
                                    .frame(width: 180, height: 260)
                                    .cornerRadius(8)

                                if showHeatmap {
                                    // Simulated Heatmap Difference Overlay
                                    Color.red.opacity(0.4)
                                        .frame(width: 180, height: 260)
                                        .cornerRadius(8)
                                    Text("Pixel Diff: 0.12%")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    // Crossfade scrubber blending baseline and current state
                                    Color.purple.opacity(diffScrubber)
                                        .frame(width: 180, height: 260)
                                        .cornerRadius(8)
                                    Text("Scrubbed: \(Int(diffScrubber * 100))%")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }

                            Slider(value: $diffScrubber, in: 0.0...1.0)
                                .frame(width: 140)
                        }

                        // Right: Current State
                        VStack {
                            Text("Current (Actual)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ZStack {
                                Color.gray.opacity(0.1)
                                    .frame(width: 140, height: 260)
                                    .cornerRadius(8)
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.purple)
                                    Text("Actual State")
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("Select a device from the sidebar or grid to compare pixel layouts and execute visual regressions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(height: 320)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
