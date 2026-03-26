import SwiftUI

@main
struct IOSLabDashboardApp: App {
    @StateObject private var runtime = BackendRuntime()
    @StateObject private var viewModel = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel, runtime: runtime)
                .task {
                    runtime.startIfNeeded()
                    await viewModel.attach(baseURL: runtime.baseURL)
                }
                .onDisappear {
                    runtime.stop()
                }
        }
    }
}