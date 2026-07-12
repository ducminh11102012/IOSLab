import SwiftUI

struct AutomationIntegrationsView: View {
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            GroupBox("CI/CD Integrations & Fastlane plugins") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("AUTOMATION CONFIGURATOR")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "circle.grid.cross.fill")
                            .foregroundColor(.blue)
                        Text("Copy Fastlane plugin code")
                            .font(.system(size: 11))
                        Spacer()
                        Button("Copy") {
                            viewModel.logs.append("Copied Fastlane plugin configuration script to pasteboard.")
                        }
                        .controlSize(.small)
                    }

                    HStack {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.purple)
                        Text("Copy GitHub Actions YAML")
                            .font(.system(size: 11))
                        Spacer()
                        Button("Copy") {
                            viewModel.logs.append("Copied GitHub Actions workflow YAML block to pasteboard.")
                        }
                        .controlSize(.small)
                    }
                }
            }

            GroupBox("Result Exports & Integrations") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export test matrix runs in standard schemas for downstream CI reporters.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Export JUnit XML Report") {
                            viewModel.logs.append("Generated JUnit XML test result report.")
                        }
                        .controlSize(.small)

                        Button("Export LCOV Coverage") {
                            viewModel.logs.append("Generated standard LCOV code coverage bundle.")
                        }
                        .controlSize(.small)
                    }
                }
            }
        }
    }
}
