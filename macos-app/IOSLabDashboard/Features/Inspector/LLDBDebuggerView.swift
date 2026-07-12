import SwiftUI

struct LLDBDebuggerView: View {
    let viewModel: DashboardViewModel
    @State private var lldbCommand: String = ""
    @State private var lldbHistory: [String] = [
        "(lldb) target create \"build/Build/Products/Debug-iphonesimulator/iOSLab.app\"",
        "Current executable set to 'build/Build/Products/Debug-iphonesimulator/iOSLab.app' (arm64).",
        "(lldb) breakpoint set --file VMEngine.swift --line 12",
        "Breakpoint 1: where = iOSLab`VMEngine.init() + 24 at VMEngine.swift:12, address = 0x00000001004a0e3c"
    ]
    @State private var showingQuickHelp = false
    @State private var selectedCertificate = "Apple Development: developer@ioslab.org (7F2B1A)"

    let certificates = [
        "Apple Development: developer@ioslab.org (7F2B1A)",
        "Apple Distribution: enterprise@ioslab.org (3A9C8D)",
        "Local Development: Ad-Hoc Self-Signed"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. LLDB Debugger Breakpoints & Variables Panel
            GroupBox("LLDB Native Target Debugger") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACTIVE BREAKPOINTS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "breakpoint.fill")
                            .foregroundColor(.blue)
                        Text("VMEngine.swift : Line 12")
                            .font(.system(size: 10, design: .monospaced))
                        Spacer()
                        Text("Active")
                            .font(.system(size: 8))
                            .foregroundColor(.green)
                    }

                    Divider()

                    Text("LOCAL VARIABLE REGISTERS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Text("self")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("VMEngine (0x0000000104b2c)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("patchTier")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("\"boot-only\"")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // REPL Output Shell
                    Text("LLDB INTERACTIVE REPL CONSOLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(lldbHistory, id: \.self) { history in
                            Text(history)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(history.hasPrefix("(lldb)") ? .blue : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(4)

                    HStack {
                        TextField("lldb command", text: $lldbCommand, onCommit: {
                            if !lldbCommand.isEmpty {
                                lldbHistory.append("(lldb) " + lldbCommand)
                                executeLldbCommand(lldbCommand)
                                lldbCommand = ""
                            }
                        })
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.small)

                        Button("Execute") {
                            if !lldbCommand.isEmpty {
                                lldbHistory.append("(lldb) " + lldbCommand)
                                executeLldbCommand(lldbCommand)
                                lldbCommand = ""
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }

            // 2. DocC Quick Help Document Panel
            GroupBox("Quick Help & Swift Documentation") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Documentation: public VMEngine")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Text("A premium virtualization state controller orchestrating genuine iOS guest images on local M-series Apple Silicon machines.")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Button(action: {
                        showingQuickHelp.toggle()
                        viewModel.logs.append("Opened full DocC documentation reader panel.")
                    }) {
                        Text("Show Full DocC Document Page")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .buttonStyle(.borderless)
                }
            }

            // 3. Signing & Capabilities Selector Panel
            GroupBox("Signing & Profiles Capabilities") {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.orange)
                        Text("Provisioning Profiles & Certificates")
                            .font(.system(size: 10, weight: .bold))
                    }

                    Picker("Signing Certificate", selection: $selectedCertificate) {
                        ForEach(certificates, id: \.self) { cert in
                            Text(cert).tag(cert)
                        }
                    }
                    .pickerStyle(.menu)
                    .controlSize(.small)

                    Toggle("Automatically manage signing", isOn: .constant(true))
                        .font(.caption2)

                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("Hardware Sandbox Capabilities Enabled")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private func executeLldbCommand(_ cmd: String) {
        viewModel.logs.append("LLDB Command executed: [\(cmd)]")
        if cmd == "po self" {
            lldbHistory.append("VMEngine instance: { patchTier: \"boot-only\", virtualMachine: null }")
        } else if cmd == "continue" || cmd == "c" {
            lldbHistory.append("Process resumed. Hit next breakpoint/run.")
        } else {
            lldbHistory.append("Unknown command: [\(cmd)]. po self, continue supported in simulator.")
        }
    }
}
