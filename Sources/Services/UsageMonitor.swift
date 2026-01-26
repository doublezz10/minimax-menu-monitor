import Foundation
import Combine

@MainActor
final class UsageMonitor: ObservableObject {
    @Published private(set) var usageData: UsageData?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var lastUpdated: Date?

    private let apiService = MiniMaxAPIService.shared
    private let keychain = KeychainService.shared
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var apiKey: String {
        Settings.shared.apiKey
    }

    var hasValidKey: Bool {
        !apiKey.isEmpty
    }

    func startMonitoring() {
        loadInitialData()
        setupRefreshTimer()
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func refresh() async {
        // Demo mode: return mock data
        if Settings.shared.demoMode {
            await generateDemoData()
            return
        }

        guard hasValidKey else {
            error = APIError.unauthorized
            return
        }

        isLoading = true
        error = nil

        do {
            let data = try await apiService.fetchUsage(apiKey: apiKey)
            self.usageData = data
            self.lastUpdated = Date()
            self.error = nil
        } catch {
            self.error = error
        }

        isLoading = false
    }

    private func generateDemoData() async {
        isLoading = true
        error = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Generate random demo data
        let total = 1_000_000
        let used = Int.random(in: 200_000...700_000)
        let remains = total - used

        self.usageData = UsageData(
            remains: remains,
            total: total,
            lastUpdated: ISO8601DateFormatter().string(from: Date())
        )
        self.lastUpdated = Date()
        self.error = nil
        isLoading = false
    }

    private func loadInitialData() {
        Task {
            await refresh()
        }
    }

    private func setupRefreshTimer() {
        refreshTimer?.invalidate()
        let interval = Settings.shared.refreshInterval
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.refresh()
            }
        }
    }

    var usagePercentage: Double {
        guard let data = usageData, data.total > 0 else { return 0 }
        return Double(data.remains) / Double(data.total)
    }

    var formattedRemaining: String {
        guard let data = usageData else { return "Unknown" }
        return formatNumber(data.remains)
    }

    var formattedTotal: String {
        guard let data = usageData else { return "Unknown" }
        return formatNumber(data.total)
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }
}
