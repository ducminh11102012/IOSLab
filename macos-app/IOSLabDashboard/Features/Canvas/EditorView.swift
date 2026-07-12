import SwiftUI

struct EditorView: View {
    let viewModel: DashboardViewModel
    @State private var codeText: String = """
import Foundation
import Virtualization

/// Hybrid Orchestration VM Lifecycle engine
public final class VMEngine {
    private let virtualMachine: VZVirtualMachine?
    private let patchTier = "boot-only"

    public init() {
        self.virtualMachine = nil
        print("VMEngine loaded with patch tier: \\(patchTier)")
    }

    public func bootPipeline() async throws {
        // [fw_prepare] -> [fw_patch] -> [restore]
        print("Executing firmware pipeline...")
    }
}
"""
    @State private var showingAutocomplete = false
    @State private var selectedAutocomplete = "bootPipeline()"

    let autocompleteSuggestions = [
        "bootPipeline() -> Void",
        "shutdown() -> Void",
        "createBackup(name: String)",
        "restoreBackup(name: String)",
        "switchConfig(cpu: Int, ram: Int)"
    ]

    var body: some View {
        GroupBox("Native Source Editor (SourceKit-LSP Integration)") {
            VStack(alignment: .leading, spacing: 10) {
                // Editor File Header Tab Info
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                    Text("Sources/VMEngine.swift")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    Spacer()
                    Text("SourceKit-LSP: Active")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }

                Divider()

                HStack(alignment: .top, spacing: 12) {
                    // Left Gutter: Gutter Gutter and Gutter Markers (Errors/Warnings inline)
                    VStack(spacing: 4) {
                        ForEach(1...18, id: \.self) { line in
                            HStack {
                                if line == 12 {
                                    // Inline compiler diagnostic marker
                                    Image(systemName: "exclamationmark.octagon.fill")
                                        .font(.system(size: 9))
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(line)")
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(height: 14)
                        }
                    }
                    .frame(width: 20)
                    .padding(.top, 4)

                    // Main Editor Area
                    VStack(alignment: .leading, spacing: 0) {
                        TextEditor(text: $codeText)
                            .font(.system(size: 12, design: .monospaced))
                            .frame(height: 250)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                            .onChange(of: codeText) { newValue in
                                if newValue.hasSuffix(".") {
                                    showingAutocomplete = true
                                }
                            }

                        if showingAutocomplete {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("LSP Autocomplete Suggestions:")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.purple)

                                ForEach(autocompleteSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        codeText += suggestion
                                        showingAutocomplete = false
                                        viewModel.logs.append("Completed code with LSP: \(suggestion)")
                                    }) {
                                        Text("• \(suggestion)")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.primary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                            .padding(.top, 8)
                        }
                    }
                }

                Divider()

                // Diagnostic Diagnostic Tooltip (Inline Xcode Compiler Error Box)
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text("VMEngine.swift:12:13: Error: Use of unresolved identifier 'VZVirtualMachine'")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.red)
                        Text("Fix-it: Import Virtualization framework or verify build settings")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Fix-it") {
                        codeText = "import Virtualization\n" + codeText
                        viewModel.logs.append("Applied automatic diagnostic Fix-it on VMEngine.swift")
                    }
                    .tint(.red)
                    .controlSize(.small)
                }
                .padding(8)
                .background(Color.red.opacity(0.05))
                .cornerRadius(6)
            }
        }
    }
}
