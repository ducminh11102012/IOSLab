import Foundation

final class APIClient {
    private let baseURL: URL
    private var wsTask: URLSessionWebSocketTask?

    init(baseURL: URL = URL(string: "http://127.0.0.1:4000")!) {
        self.baseURL = baseURL
    }

    func fetchDevices() async throws -> [DeviceModel] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("devices"))
        return try JSONDecoder().decode(DevicesResponse.self, from: data).items
    }

    func fetchJobs() async throws -> [JobModel] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("tests"))
        return try JSONDecoder().decode(JobsResponse.self, from: data).items
    }

    func fetchMetrics() async throws -> MetricsModel {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("metrics/summary"))
        return try JSONDecoder().decode(MetricsModel.self, from: data)
    }

    func post(path: String, body: Data) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        _ = try await URLSession.shared.data(for: request)
    }

    func connectLogs(onMessage: @escaping (String) -> Void, onDisconnect: @escaping () -> Void) {
        guard let wsURL = URL(string: "ws://127.0.0.1:4000/ws/logs") else { return }
        wsTask = URLSession.shared.webSocketTask(with: wsURL)
        wsTask?.resume()

        func receive() {
            wsTask?.receive { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text): onMessage(text)
                    case .data(let data): onMessage(String(data: data, encoding: .utf8) ?? "")
                    @unknown default: break
                    }
                    receive()
                case .failure:
                    onDisconnect()
                }
            }
        }

        receive()
    }

    func disconnectLogs() {
        wsTask?.cancel(with: .normalClosure, reason: nil)
    }
}
