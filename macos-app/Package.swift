// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IOSLabDashboardCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "IOSLabDashboardCore", targets: ["IOSLabDashboardCore"])
    ],
    targets: [
        .target(name: "IOSLabDashboardCore"),
        .testTarget(name: "IOSLabDashboardCoreTests", dependencies: ["IOSLabDashboardCore"])
    ]
)
