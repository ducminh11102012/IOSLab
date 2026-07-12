import SwiftUI

struct StorageDashboardView: View {
    let viewModel: DashboardViewModel
    @State private var vmDiskUsageGb: Double = 124.0
    @State private var cacheDiskUsageGb: Double = 18.4
    @State private var artifactDiskUsageGb: Double = 32.2

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Data Lifecycle & Disk Storage Metrics") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("TOTAL DISK CAPACITY USED")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "internaldrive")
                            .font(.title2)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading) {
                            Text("\((vmDiskUsageGb + cacheDiskUsageGb + artifactDiskUsageGb).formatted("%.1f")) GB")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                            Text("Large VM configurations & cached builds found")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    Text("BREAKDOWN STORAGE ANALYSIS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    StorageProgressBar(vm: vmDiskUsageGb, cache: cacheDiskUsageGb, artifacts: artifactDiskUsageGb)

                    VStack(spacing: 4) {
                        StorageLegendRow(color: .purple, name: "Virtualized Guest VM Images", size: "\(vmDiskUsageGb) GB")
                        StorageLegendRow(color: .orange, name: "Cached SPM/Xcode builds", size: "\(cacheDiskUsageGb) GB")
                        StorageLegendRow(color: .blue, name: "Visual test run artifacts", size: "\(artifactDiskUsageGb) GB")
                    }
                }
            }

            GroupBox("Retention auto-cleanup Sweep") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set old visual screenshots, test records, and temporary builds auto-pruning thresholds.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    Button(action: {
                        viewModel.logs.append("Executing storage retention policy cleanup...")
                        // Simulate reclaiming disk space
                        artifactDiskUsageGb = 1.2
                        viewModel.logs.append("Successfully reclaimed 31.0 GB of storage disk capacity!")
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Reclaim Storage Disk Space")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .tint(.purple)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct StorageProgressBar: View {
    let vm: Double
    let cache: Double
    let artifacts: Double

    var body: some View {
        let total = vm + cache + artifacts
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.purple
                    .frame(width: geo.size.width * CGFloat(vm / total))
                Color.orange
                    .frame(width: geo.size.width * CGFloat(cache / total))
                Color.blue
                    .frame(width: geo.size.width * CGFloat(artifacts / total))
            }
        }
        .frame(height: 10)
        .cornerRadius(5)
    }
}

struct StorageLegendRow: View {
    let color: Color
    let name: String
    let size: String

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.system(size: 9))
            Spacer()
            Text(size)
                .font(.system(size: 9, design: .monospaced, weight: .bold))
        }
    }
}
