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
    
    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
        cancellables.removeAll()
    }
    
    func startMonitoring() {
        loadInitialData()
        setupRefreshTimer()
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Listen for context menu refresh action
        NotificationCenter.default.addObserver(
            forName: Notification.Name("refreshUsage"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
    }
    
    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refresh() async {
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
        usageData?.usagePercentage ?? 0
    }
    
    var formattedRemaining: String {
        guard let data = usageData else { return "Unknown" }
        return formatNumber(data.remainingCount)
    }
    
    var formattedTotal: String {
        guard let data = usageData else { return "Unknown" }
        return formatNumber(data.totalCount)
    }
    
    var formattedUsed: String {
        guard let data = usageData else { return "—" }
        return formatNumber(data.usedCount)
    }
    
    var modelName: String {
        usageData?.modelName ?? "Unknown"
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
