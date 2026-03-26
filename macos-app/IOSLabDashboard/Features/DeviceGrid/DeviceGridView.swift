import SwiftUI

struct DeviceGridView: View {
    let devices: [DeviceModel]

    var body: some View {
        GroupBox("Devices") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 8) {
                ForEach(devices) { device in
                    VStack(alignment: .leading) {
                        Text(device.name).bold()
                        Text(device.runtime).font(.caption)
                        Text(device.status).font(.caption2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}
