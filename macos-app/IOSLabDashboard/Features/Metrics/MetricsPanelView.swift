import SwiftUI

struct MetricsPanelView: View {
    let metrics: MetricsModel

    var body: some View {
        GroupBox("Metrics") {
            HStack {
                Text("Devices: \(metrics.devices)")
                Text("Jobs: \(metrics.jobs)")
                Text("Queue: \(metrics.queueDepth)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
