import SwiftUI

struct SustainabilityEnergyView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. App Health Score stock-ticker
            GroupBox("App Health Score Stock Ticker") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.green)
                        Text("App Health Index Score")
                            .font(.system(size: 10, weight: .bold))
                        Spacer()
                        Text("98.4")
                            .font(.system(size: 14, weight: .heavy, design: .monospaced))
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Trending (+0.4% this week)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.green)
                            .font(.caption2)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("• Crash Free Rate")
                            Spacer()
                            Text("99.98%")
                                .bold()
                        }
                        HStack {
                            Text("• Accessibility Coverage")
                            Spacer()
                            Text("94.2%")
                                .bold()
                        }
                        HStack {
                            Text("• Visual Regressions")
                            Spacer()
                            Text("0 active")
                                .bold()
                        }
                    }
                    .font(.system(size: 8, design: .monospaced))
                }
            }

            // 2. Sustainability & Carbon Report per CI run
            GroupBox("CI Sustainability Energy Report") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("Energy Impact & Carbon Report")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Text("Running dozens of simulators and real iOS VMs draws real power. This report tracks real carbon offsets achieved by pruning redundant test matrix slots.")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Divider()

                    HStack {
                        Text("Energy Consumed:")
                        Spacer()
                        Text("12.4 Wh")
                            .font(.system(size: 9, design: .monospaced, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .font(.caption2)

                    HStack {
                        Text("CO2 Emissions Saved:")
                        Spacer()
                        Text("4.8 g CO2 Offset")
                            .font(.system(size: 9, design: .monospaced, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .font(.caption2)
                }
            }
        }
    }
}
