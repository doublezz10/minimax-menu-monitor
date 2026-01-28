import Foundation
import Combine

final class Settings: ObservableObject {
    static let shared = Settings()

    /// API key is read-only from Keychain - NEVER stored in UserDefaults for security
    var apiKey: String {
        get {
            do {
                return try KeychainService.shared.load()
            } catch {
                return ""
            }
        }
        set {
            // Save new key to Keychain only
            do {
                if newValue.isEmpty {
                    try KeychainService.shared.delete()
                } else {
                    try KeychainService.shared.save(key: newValue)
                }
                // Post notification so UsageMonitor can react
                NotificationCenter.default.post(name: .apiKeyChanged, object: nil)
            } catch {
                print("Failed to save API key to keychain: \(error)")
            }
        }
    }

    @Published var refreshInterval: TimeInterval {
        didSet { save() }
    }

    @Published var showPercentage: Bool {
        didSet { save() }
    }

    @Published var useGradient: Bool {
        didSet { save() }
    }

    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults.standard

        // Load saved values or use defaults
        let loadedRefreshInterval = defaults.double(forKey: "refreshInterval")
        refreshInterval = loadedRefreshInterval > 0 ? loadedRefreshInterval : 60
        showPercentage = defaults.bool(forKey: "showPercentage")
        useGradient = defaults.bool(forKey: "useGradient")
        // Note: apiKey is NOT loaded from UserDefaults - only from Keychain
    }

    private func save() {
        // API key is NOT saved here - it goes directly to Keychain
        defaults.set(refreshInterval, forKey: "refreshInterval")
        defaults.set(showPercentage, forKey: "showPercentage")
        defaults.set(useGradient, forKey: "useGradient")
    }

    /// Clear API key from Keychain and UserDefaults
    func clear() {
        do {
            try KeychainService.shared.delete()
        } catch {
            print("Failed to delete key from keychain: \(error)")
        }
        defaults.removeObject(forKey: "apiKey")
        NotificationCenter.default.post(name: .apiKeyChanged, object: nil)
    }

    /// Check if API key is configured
    var hasApiKey: Bool {
        !apiKey.isEmpty
    }
}

extension Notification.Name {
    static let apiKeyChanged = Notification.Name("apiKeyChanged")
}
