import SwiftUI

struct MatrixTableView: View {
    let devices: [DeviceModel]
    let jobs: [JobModel]

    var body: some View {
        GroupBox("Test Matrix Target Status Map") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Dense Coverage Matrix Overview")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                Table(devices) {
                    TableColumn("Device Name", value: \.name)
                    TableColumn("Type") { d in
                        Text(d.type?.uppercased() ?? "SIMULATOR")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(d.type == "vm" ? .purple : .blue)
                    }
                    TableColumn("OS Runtime") { d in
                        Text(d.runtime.components(separatedBy: ".").last ?? "iOS 18.0")
                            .font(.caption2)
                    }
                    TableColumn("Device Status") { d in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(d.status == "ready" ? Color.green : (d.status == "busy" ? Color.purple : Color.gray))
                                .frame(width: 6, height: 6)
                            Text(d.status.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(d.status == "ready" ? .green : .orange)
                        }
                    }
                    TableColumn("Current Job") { d in
                        if d.status == "busy" {
                            Text("Running Suite: AppTests")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        } else {
                            Text("Idle / Waiting")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 260)
            }
        }
    }
}
