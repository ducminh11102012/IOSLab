import Foundation

struct DeviceModel: Codable, Identifiable {
    let id: String
    let name: String
    let status: String
    let runtime: String
    let type: String?
    let variant: String?
    let currentPatchTier: String?
    let backupList: [String]?
    let cpu: Int?
    let memory: Int?
    let disk: Int?
    let screen: String?
    let modelId: String?
}

struct JobModel: Codable, Identifiable {
    let id: String
    let testTarget: String
    let status: String
    let retries: Int
}

struct MetricsModel: Codable {
    let devices: Int
    let jobs: Int
    let queueDepth: Int
}

struct DevicesResponse: Codable { let items: [DeviceModel] }
struct JobsResponse: Codable { let items: [JobModel] }
