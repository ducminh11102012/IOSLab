import Foundation

public struct DashboardDevice: Equatable {
    public let id: String
    public let status: String

    public init(id: String, status: String) {
        self.id = id
        self.status = status
    }
}

public struct DashboardJob: Equatable {
    public let id: String
    public let status: String

    public init(id: String, status: String) {
        self.id = id
        self.status = status
    }
}

@MainActor
public protocol DashboardService {
    func fetchDevices() async throws -> [DashboardDevice]
    func runTest(target: String) async throws -> DashboardJob
}

@MainActor
public final class DashboardController {
    public private(set) var devices: [DashboardDevice] = []
    public private(set) var jobs: [DashboardJob] = []
    public private(set) var logs: [String] = []

    private let service: DashboardService

    public init(service: DashboardService) {
        self.service = service
    }

    public func loadDevices() async {
        do {
            devices = try await service.fetchDevices()
            logs.append("loaded_devices")
        } catch {
            logs.append("load_failed")
        }
    }

    public func triggerTest(target: String) async {
        do {
            let job = try await service.runTest(target: target)
            jobs.append(job)
            logs.append("test_triggered")
        } catch {
            logs.append("test_failed")
        }
    }

    public func appendLog(_ message: String) {
        logs.append(message)
    }
}
