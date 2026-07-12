import SwiftUI

struct ResourceTimelineView: View {
    let devices: [DeviceModel]
    @State private var timeOffset: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.purple)
                Text("Instruments Core Resource Profiler (Real-time CPU/Memory Pressure Lanes)")
                    .font(.system(size: 10, weight: .bold))
                Spacer()
                Text("Timeline: Live Streaming")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            Divider()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(devices) { device in
                        let isVM = device.type == "vm"

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(device.name)
                                    .font(.system(size: 9, weight: .bold))
                                Spacer()
                                Text(isVM ? "VM Lane" : "SIM Lane")
                                    .font(.system(size: 7, weight: .semibold))
                                    .foregroundColor(isVM ? .purple : .blue)
                            }

                            // Visual Instruments Flame Lane representing CPU usage timeline over time
                            HStack(spacing: 1) {
                                ForEach(0..<20, id: \.self) { index in
                                    // Generate simulated flame height based on device state
                                    let randHeight: CGFloat = (device.status == "busy")
                                        ? CGFloat.random(in: 12...32)
                                        : CGFloat.random(in: 2...8)

                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(isVM ? Color.purple : Color.blue)
                                        .frame(width: 3, height: randHeight)
                                        .animation(.interactiveSpring, value: randHeight)
                                }
                            }
                            .frame(height: 36, alignment: .bottom)
                            .frame(width: 80)
                            .background(Color.black.opacity(0.03))
                            .cornerRadius(4)

                            HStack {
                                Text("CPU: \((device.status == "busy") ? Int.random(in: 45...88) : Int.random(in: 2...12))%")
                                Spacer()
                                Text("RAM: \((device.status == "busy") ? Int.random(in: 60...92) : Int.random(in: 5...25))%")
                            }
                            .font(.system(size: 7, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                        )
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
    }
}
