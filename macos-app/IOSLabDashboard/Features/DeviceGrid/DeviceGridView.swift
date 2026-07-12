import SwiftUI

struct DeviceGridView: View {
    let devices: [DeviceModel]
    var zoomScale: Double = 1.0
    var onSelectDevice: ((DeviceModel) -> Void)? = nil

    var body: some View {
        GroupBox("Unified Device Pool (Simulators & VMs)") {
            let minWidth = CGFloat(200 * zoomScale)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: minWidth))], spacing: CGFloat(12 * zoomScale)) {
                ForEach(devices) { device in
                    let isVM = device.type == "vm"

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(device.name)
                                .bold()
                                .font(.headline)
                                .foregroundColor(isVM ? .purple : .primary)

                            Spacer()

                            // Badge indicating Simulator or VM
                            Text(isVM ? "REAL VM" : "SIMULATOR")
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isVM ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundColor(isVM ? .purple : .blue)
                                .cornerRadius(4)
                        }

                        Text("Runtime: \(device.runtime)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Status: \(device.status.uppercased())")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(device.status == "ready" ? .green : .orange)

                        if isVM {
                            VStack(alignment: .leading, spacing: 2) {
                                Divider()
                                    .padding(.vertical, 2)
                                Text("Hardware Profile:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.purple)
                                Text("• CPU Cores: \(device.cpu ?? 4)")
                                    .font(.system(size: 9))
                                Text("• Memory: \(device.memory ?? 6) GB")
                                    .font(.system(size: 9))
                                Text("• Disk: \(device.disk ?? 64) GB")
                                    .font(.system(size: 9))
                                Text("• Patch Tier: \(device.currentPatchTier ?? "boot-only")")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Divider()
                                    .padding(.vertical, 2)
                                Text("Simulator Profile:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("• Model ID: \(device.modelId ?? "iPhone 15")")
                                    .font(.system(size: 9))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(isVM ? Color.purple.opacity(0.05) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isVM ? Color.purple.opacity(0.3) : Color.gray.opacity(0.15), lineWidth: isVM ? 2 : 1)
                    )
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelectDevice?(device)
                    }
                }
            }
        }
    }
}
