import Foundation
import Combine

final class Settings: ObservableObject {
    static let shared = Settings()

    @Published var apiKey: String {
        didSet { save() }
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
        apiKey = defaults.string(forKey: "apiKey") ?? ""
    }

    private func save() {
        defaults.set(apiKey, forKey: "apiKey")
        defaults.set(refreshInterval, forKey: "refreshInterval")
        defaults.set(showPercentage, forKey: "showPercentage")
        defaults.set(useGradient, forKey: "useGradient")
    }

    func clear() {
        apiKey = ""
        defaults.removeObject(forKey: "apiKey")
    }
}
