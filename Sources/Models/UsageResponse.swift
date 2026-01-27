import Foundation

struct UsageResponse: Codable {
    let modelRemains: [ModelUsage]?
    let baseResp: BaseResponse?

    enum CodingKeys: String, CodingKey {
        case modelRemains = "model_remains"
        case baseResp = "base_resp"
    }
}

struct BaseResponse: Codable {
    let statusCode: Int?
    let statusMsg: String?

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMsg = "status_msg"
    }
}

struct ModelUsage: Codable {
    let startTime: Int64
    let endTime: Int64
    let remainsTime: Int
    let currentIntervalTotalCount: Int
    let currentIntervalUsageCount: Int
    let modelName: String?

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case remainsTime = "remains_time"
        case currentIntervalTotalCount = "current_interval_total_count"
        case currentIntervalUsageCount = "current_interval_usage_count"
        case modelName = "model_name"
    }
}

struct UsageData {
    let totalCount: Int
    let usedCount: Int
    let remainingCount: Int
    let remainingTimeMs: Int
    let startTimeMs: Int64
    let endTimeMs: Int64
    let modelName: String?

    var usagePercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(usedCount) / Double(totalCount)
    }

    var remainingTimeSeconds: Int {
        remainingTimeMs / 1000
    }
}

struct UsageError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
