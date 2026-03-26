import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var devices: [DeviceModel] = []
    @Published var jobs: [JobModel] = []
    @Published var metrics = MetricsModel(devices: 0, jobs: 0, queueDepth: 0)
    @Published var logs: [String] = []

    private let apiClient = APIClient()
    private var pollTimer: Timer?

    func start() async {
        await refresh()
        connectLogs()
    }

    func refresh() async {
        do {
            async let d = apiClient.fetchDevices()
            async let j = apiClient.fetchJobs()
            async let m = apiClient.fetchMetrics()
            devices = try await d
            jobs = try await j
            metrics = try await m
        } catch {
            logs.append("Refresh failed: \(error.localizedDescription)")
        }
    }

    func spawnDefaultDevice() async {
        let payload = ["name": "iPhone 15", "runtime": "com.apple.CoreSimulator.SimRuntime.iOS-18-0", "modelId": "com.apple.CoreSimulator.SimDeviceType.iPhone-15"]
        do {
            let body = try JSONSerialization.data(withJSONObject: payload)
            try await apiClient.post(path: "devices/spawn", body: body)
            await refresh()
        } catch {
            logs.append("Spawn failed: \(error.localizedDescription)")
        }
    }

    func runDefaultTest() async {
        let payload = ["testTarget": "AppTests"]
        do {
            let body = try JSONSerialization.data(withJSONObject: payload)
            try await apiClient.post(path: "tests/run", body: body)
            await refresh()
        } catch {
            logs.append("Run test failed: \(error.localizedDescription)")
        }
    }

    func connectLogs() {
        apiClient.connectLogs { [weak self] text in
            Task { @MainActor in self?.logs.append(text) }
        } onDisconnect: { [weak self] in
            Task { @MainActor in
                self?.logs.append("WebSocket disconnected, enabling polling fallback")
                self?.startPollingFallback()
            }
        }
    }

    private func startPollingFallback() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }
}
