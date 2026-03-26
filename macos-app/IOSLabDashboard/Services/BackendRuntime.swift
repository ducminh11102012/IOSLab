import Foundation

@MainActor
final class BackendRuntime: ObservableObject {
    @Published private(set) var status: String = "stopped"

    private var process: Process?
    private let port: Int

    init(port: Int = 47123) {
        self.port = port
    }

    var baseURL: URL {
        URL(string: "http://127.0.0.1:\(port)")!
    }

    func startIfNeeded() {
        guard process == nil else { return }

        let executable = Bundle.main.path(forResource: "start-backend", ofType: "sh", inDirectory: "backend-runtime")
        guard let executable else {
            status = "missing-runtime"
            return
        }

        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/bash")
        p.arguments = [executable]

        var env = ProcessInfo.processInfo.environment
        env["PORT"] = String(port)
        env["HOST"] = "127.0.0.1"
        env["IOSLAB_SIMULATOR_MOCK"] = env["IOSLAB_SIMULATOR_MOCK"] ?? "false"
        p.environment = env

        do {
            try p.run()
            process = p
            status = "running"
        } catch {
            status = "failed: \(error.localizedDescription)"
        }
    }

    func stop() {
        process?.terminate()
        process = nil
        status = "stopped"
    }
}
