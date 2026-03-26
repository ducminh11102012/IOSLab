import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Spawn") { Task { await viewModel.spawnDefaultDevice() } }
                Button("Run Test") { Task { await viewModel.runDefaultTest() } }
                Button("Refresh") { Task { await viewModel.refresh() } }
            }

            DeviceGridView(devices: viewModel.devices)
            TestTimelineView(jobs: viewModel.jobs)
            MetricsPanelView(metrics: viewModel.metrics)
            LogsPanelView(logs: viewModel.logs)
        }
        .padding()
        .task { await viewModel.start() }
    }
}
