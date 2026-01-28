import XCTest
@testable import MinimaxMenuMonitor

final class MiniMaxAPIServiceTests: XCTestCase {

    // MARK: - Test Setup

    var apiService: MiniMaxAPIService!

    override func setUp() {
        super.setUp()
        apiService = MiniMaxAPIService()
    }

    override func tearDown() {
        apiService = nil
        super.tearDown()
    }

    // MARK: - API Error Tests

    func testAPIErrorDescriptions() {
        // Test invalid URL error
        let invalidURLError = APIError.invalidURL
        XCTAssertNotNil(invalidURLError.errorDescription)
        XCTAssertTrue(invalidURLError.errorDescription!.contains("Invalid URL"))

        // Test no data error
        let noDataError = APIError.noData
        XCTAssertNotNil(noDataError.errorDescription)
        XCTAssertTrue(noDataError.errorDescription!.contains("No data"))

        // Test unauthorized error
        let unauthorizedError = APIError.unauthorized
        XCTAssertNotNil(unauthorizedError.errorDescription)
        XCTAssertTrue(unauthorizedError.errorDescription!.contains("API key"))

        // Test rate limited error
        let rateLimitedError = APIError.rateLimited(retryAfter: 60)
        XCTAssertNotNil(rateLimitedError.errorDescription)
        XCTAssertTrue(rateLimitedError.errorDescription!.contains("Rate limited"))
        XCTAssertEqual(rateLimitedError.recoverySuggestion?.contains("wait"), true)

        // Test server error
        let serverError = APIError.serverError(500, "Internal Server Error")
        XCTAssertNotNil(serverError.errorDescription)
        XCTAssertTrue(serverError.errorDescription!.contains("500"))
        XCTAssertTrue(serverError.errorDescription!.contains("Internal Server Error"))
    }

    // MARK: - Settings Tests

    func testSettingsDefaultValues() {
        let settings = Settings.shared

        // Test default refresh interval
        XCTAssertEqual(settings.refreshInterval, 60.0)
    }

    func testSettingsPersistence() {
        let settings = Settings.shared

        // Test refresh interval update
        let newInterval: Double = 120
        settings.refreshInterval = newInterval
        XCTAssertEqual(settings.refreshInterval, newInterval)
    }

    // MARK: - Usage Data Calculations

    func testUsageDataPercentage() {
        // Test with known values
        let usageData = UsageData(
            totalCount: 1000000,
            usedCount: 250000,
            remainingCount: 750000,
            remainingTimeMs: 86400000,
            startTimeMs: 0,
            endTimeMs: 86400000,
            modelName: "test-model"
        )

        // Verify usage percentage calculation
        let expectedPercentage = 0.25 // 250000 / 1000000
        XCTAssertEqual(usageData.usagePercentage, expectedPercentage, accuracy: 0.001)
    }

    func testUsageDataEdgeCases() {
        // Test zero usage
        let zeroUsage = UsageData(
            totalCount: 1000000,
            usedCount: 0,
            remainingCount: 1000000,
            remainingTimeMs: 86400000,
            startTimeMs: 0,
            endTimeMs: 86400000,
            modelName: "test-model"
        )
        XCTAssertEqual(zeroUsage.usagePercentage, 0.0, accuracy: 0.001)

        // Test full usage
        let fullUsage = UsageData(
            totalCount: 1000000,
            usedCount: 1000000,
            remainingCount: 0,
            remainingTimeMs: 0,
            startTimeMs: 0,
            endTimeMs: 0,
            modelName: "test-model"
        )
        XCTAssertEqual(fullUsage.usagePercentage, 1.0, accuracy: 0.001)
    }
}

    override func tearDown() {
        apiService = nil
        mockURLSession = nil
        super.tearDown()
    }

    // MARK: - API Error Tests

    func testAPIErrorDescriptions() {
        // Test invalid URL error
        let invalidURLError = APIError.invalidURL
        XCTAssertNotNil(invalidURLError.errorDescription)
        XCTAssertTrue(invalidURLError.errorDescription!.contains("Invalid URL"))

        // Test no data error
        let noDataError = APIError.noData
        XCTAssertNotNil(noDataError.errorDescription)
        XCTAssertTrue(noDataError.errorDescription!.contains("No data"))

        // Test unauthorized error
        let unauthorizedError = APIError.unauthorized
        XCTAssertNotNil(unauthorizedError.errorDescription)
        XCTAssertTrue(unauthorizedError.errorDescription!.contains("API key"))

        // Test rate limited error
        let rateLimitedError = APIError.rateLimited(retryAfter: 60)
        XCTAssertNotNil(rateLimitedError.errorDescription)
        XCTAssertTrue(rateLimitedError.errorDescription!.contains("Rate limited"))
        XCTAssertEqual(rateLimitedError.recoverySuggestion?.contains("wait"), true)

        // Test server error
        let serverError = APIError.serverError(500, "Internal Server Error")
        XCTAssertNotNil(serverError.errorDescription)
        XCTAssertTrue(serverError.errorDescription!.contains("500"))
        XCTAssertTrue(serverError.errorDescription!.contains("Internal Server Error"))
    }

    // MARK: - Settings Tests

    func testSettingsDefaultValues() {
        let settings = Settings.shared

        // Test default refresh interval
        XCTAssertEqual(settings.refreshInterval, 60.0)
    }

    func testSettingsPersistence() {
        let settings = Settings.shared

        // Test refresh interval update
        let newInterval: Double = 120
        settings.refreshInterval = newInterval
        XCTAssertEqual(settings.refreshInterval, newInterval)
    }

    // MARK: - Usage Data Calculations

    func testUsageDataPercentage() {
        // Test with known values
        let usageData = UsageData(
            totalCount: 1000000,
            usedCount: 250000,
            remainingCount: 750000,
            remainingTimeMs: 86400000,
            startTimeMs: 0,
            endTimeMs: 86400000,
            modelName: "test-model"
        )

        // Verify usage percentage calculation
        let expectedPercentage = 0.25 // 250000 / 1000000
        XCTAssertEqual(usageData.usagePercentage, expectedPercentage, accuracy: 0.001)
    }

    func testUsageDataEdgeCases() {
        // Test zero usage
        let zeroUsage = UsageData(
            totalCount: 1000000,
            usedCount: 0,
            remainingCount: 1000000,
            remainingTimeMs: 86400000,
            startTimeMs: 0,
            endTimeMs: 86400000,
            modelName: "test-model"
        )
        XCTAssertEqual(zeroUsage.usagePercentage, 0.0,.001)

        accuracy: 0 // Test full usage
        let fullUsage = UsageData(
            totalCount: 1000000,
            usedCount: 1000000,
            remainingCount: 0,
            remainingTimeMs: 0,
            startTimeMs: 0,
            endTimeMs: 0,
            modelName: "test-model"
        )
        XCTAssertEqual(fullUsage.usagePercentage, 1.0, accuracy: 0.001)
    }
}

// MARK: - Mock URL Session

class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw APIError.noData
        }
        return (data, response)
    }
}

// MARK: - Usage Response Models

extension UsageResponse {
    static func mock(success: Bool = true, modelName: String = "test-model", total: Int = 1000000, used: Int = 250000) -> UsageResponse {
        let baseResp = BaseResp(statusCode: success ? 0 : 1, statusMsg: success ? "success" : "error")
        let modelRemain = ModelRemain(
            modelName: modelName,
            currentIntervalTotalCount: total,
            currentIntervalUsageCount: used,
            remainsTime: 86400000,
            startTime: 0,
            endTime: 86400000
        )

        return UsageResponse(baseResp: baseResp, modelRemains: [modelRemain])
    }
}
