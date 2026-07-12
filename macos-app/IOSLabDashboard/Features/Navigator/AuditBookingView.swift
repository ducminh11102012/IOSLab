import SwiftUI

struct AuditBookingView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("Security Audit Logs (Access Control)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PLATFORM WORKSPACE AUDITING")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        AuditRow(time: "10:14:12", user: "admin", action: "Provisioned real guest VM")
                        AuditRow(time: "10:11:05", user: "dev_alice", action: "Approved layout baseline change")
                        AuditRow(time: "09:58:32", user: "system", action: "Executed nightly cron-sweep")
                    }
                }
            }

            GroupBox("Device Pool Reservations & Booking") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("discover and lock guest VM and simulator slots on shared Mac infrastructure.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.purple)
                        Text("Current Slot Booking:")
                            .font(.system(size: 10, weight: .bold))
                        Spacer()
                        Text("Available")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }

                    Button("Book Pool Slot for 1 hour") {
                        viewModel.logs.append("Reserved local hypervisor device pool slot for 60 minutes.")
                    }
                    .controlSize(.small)
                    .tint(.purple)
                }
            }
        }
    }
}

struct AuditRow: View {
    let time: String
    let user: String
    let action: String

    var body: some View {
        HStack(spacing: 6) {
            Text(time)
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.secondary)
            Text("[\(user)]")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.purple)
            Text(action)
                .font(.system(size: 9))
                .lineLimit(1)
            Spacer()
        }
    }
}
