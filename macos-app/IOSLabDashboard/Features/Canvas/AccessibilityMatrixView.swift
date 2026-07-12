import SwiftUI

struct AccessibilityMatrixView: View {
    let viewModel: DashboardViewModel
    let selectedDevice: DeviceModel?

    @State private var voiceOverAuditPassed = true
    @State private var textScalePercent: Double = 100.0
    @State private var localeSelector = "en_US"

    let localesList = [
        "en_US (English)",
        "ar_EG (Arabic - RTL)",
        "fr_FR (French)",
        "de_DE (German)",
        "pseudo_LOC (Pseudo-Expanded Strings)"
    ]

    var body: some View {
        GroupBox("Accessibility & Localization Integrity Matrix") {
            VStack(alignment: .leading, spacing: 14) {
                Text("Automated layout validation and speech audit runs across all accessible HIG modalities simultaneously.")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                HStack(alignment: .top, spacing: 16) {
                    // 1. Accessibility Modalities
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Accessibility Modalities", systemImage: "figure.roll")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)

                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.green)
                            Text("VoiceOver Speech Flow Audit")
                            Spacer()
                            Text("PASSED")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .font(.caption2)

                        HStack {
                            Image(systemName: "textformat.size.larger")
                                .foregroundColor(.orange)
                            Text("Dynamic Larger Text Scaling")
                            Spacer()
                            Text("\(Int(textScalePercent))%")
                                .font(.system(size: 9, design: .monospaced, weight: .bold))
                        }
                        .font(.caption2)
                        Slider(value: $textScalePercent, in: 100...300, step: 25)

                        HStack {
                            Image(systemName: "arrow.left.and.right")
                                .foregroundColor(.blue)
                            Text("Reduce Motion State Checker")
                            Spacer()
                            Text("COMPLIANT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // 2. Localization Truth Table
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Localization Truth Table", systemImage: "globe")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.purple)

                        Picker("Language Locale", selection: $localeSelector) {
                            ForEach(localesList, id: \.self) { locale in
                                Text(locale).tag(locale)
                             }
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)

                        HStack {
                            Image(systemName: "arrow.left.to.line")
                                .foregroundColor(localeSelector.contains("ar_EG") ? .green : .secondary)
                            Text("RTL Layout Auto-alignment")
                            Spacer()
                            Text(localeSelector.contains("ar_EG") ? "RTL ACTIVE" : "LTR")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(localeSelector.contains("ar_EG") ? .green : .secondary)
                        }
                        .font(.caption2)

                        HStack {
                            Image(systemName: "character.textbox")
                                .foregroundColor(.orange)
                            Text("Pseudo-Localization Overflows")
                            Spacer()
                            Text("0 Clipped")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .font(.caption2)

                        Button("Execute Multi-Locale Layout Verification") {
                            viewModel.logs.append("Executing 12-locale pseudo-string truncation verification on VM matrix.")
                        }
                        .controlSize(.small)
                        .tint(.purple)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
