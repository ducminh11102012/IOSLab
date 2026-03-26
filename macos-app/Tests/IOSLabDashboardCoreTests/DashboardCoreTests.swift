import XCTest
@testable import IOSLabDashboardCore

private struct MockService: DashboardService {
    func fetchDevices() async throws -> [DashboardDevice] {
        [DashboardDevice(id: "dev-1", status: "ready")]
    }

    func runTest(target: String) async throws -> DashboardJob {
        DashboardJob(id: "job-1", status: "queued")
    }
}

@MainActor
final class DashboardCoreTests: XCTestCase {
    func testShowDevicesTriggerTestAndUpdateLogs() async {
        let controller = DashboardController(service: MockService())

        await controller.loadDevices()
        XCTAssertEqual(controller.devices.count, 1)

        await controller.triggerTest(target: "AppTests")
        XCTAssertEqual(controller.jobs.count, 1)

        controller.appendLog("log_line")
        XCTAssertTrue(controller.logs.contains("log_line"))
    }
}
