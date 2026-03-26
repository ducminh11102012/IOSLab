import XCTest
@testable import IOSLabDashboard

final class DashboardViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = DashboardViewModel()
        XCTAssertEqual(vm.devices.count, 0)
        XCTAssertEqual(vm.jobs.count, 0)
        XCTAssertEqual(vm.metrics.queueDepth, 0)
    }
}
