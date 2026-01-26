import Foundation

struct UsageResponse: Codable {
    let code: Int
    let msg: String
    let data: UsageData?
}

struct UsageData: Codable {
    let remains: Int
    let total: Int
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case remains
        case total
        case lastUpdated = "last_updated"
    }
}

struct UsageError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
