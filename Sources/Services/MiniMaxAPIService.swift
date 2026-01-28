import Foundation

// MARK: - API Error
// Comprehensive error handling with user-friendly messages

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case rateLimited(retryAfter: TimeInterval)
    case serverError(Int, String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration. Please restart the app."
        case .noData:
            return "No data received from the server. Please try again."
        case .decodingError(let error):
            return "Failed to process server response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription). Please check your connection."
        case .unauthorized:
            return "Invalid API key. Please check your credentials in Settings."
        case .rateLimited(let retryAfter):
            return "Rate limited. Please wait \(Int(retryAfter)) seconds before retrying."
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "Unknown error")"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Open Settings to update your API key"
        case .rateLimited:
            return "The app will automatically retry after the cooldown period"
        case .networkError:
            return "Check your internet connection and try again"
        default:
            return nil
        }
    }
}

final class MiniMaxAPIService {
    static let shared = MiniMaxAPIService()

    private let baseURL = "https://www.minimax.io/v1/api/openplatform/coding_plan/remains"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }

    func fetchUsage(apiKey: String) async throws -> UsageData {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "Invalid response", code: -1))
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                let usageResponse = try decoder.decode(UsageResponse.self, from: data)
                
                // Check if response indicates success
                if usageResponse.baseResp?.statusCode == 0,
                   let modelRemains = usageResponse.modelRemains,
                   let firstModel = modelRemains.first {
                    // Note: current_interval_usage_count contains REMAINING count (bad naming in API)
                    let totalCount = firstModel.currentIntervalTotalCount
                    let remainingCount = firstModel.currentIntervalUsageCount
                    let usedCount = totalCount - remainingCount
                    
                    return UsageData(
                        totalCount: totalCount,
                        usedCount: usedCount,
                        remainingCount: remainingCount,
                        remainingTimeMs: firstModel.remainsTime,
                        startTimeMs: firstModel.startTime,
                        endTimeMs: firstModel.endTime,
                        modelName: firstModel.modelName
                    )
                } else {
                    throw APIError.noData
                }
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 429:
            throw APIError.rateLimited(retryAfter: 60)
        default:
            throw APIError.serverError(httpResponse.statusCode, nil)
        }
    }
}
