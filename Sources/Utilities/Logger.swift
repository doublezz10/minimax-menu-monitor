import os.log

// MARK: - Logging System
// Centralized logging for debugging and monitoring with proper macOS integration

/// Centralized logger using OSLog for proper macOS integration
/// Provides debug, info, error, and fault level logging with automatic context
enum AppLogger {
    // MARK: - Configuration
    
    /// Subsystem identifier for log filtering
    static let subsystem = "com.minimaxmenu.MinimaxMenuMonitor"
    
    /// Whether to include file/function/line context in log messages
    static var includeContext = true
    
    // MARK: - Private Helpers
    
    /// Create a logger instance for a specific file/category
    private static func logger(for file: String = #file, function: String = #function, line: Int = #line) -> OSLog {
        let filename = (file as NSString).lastPathComponent
        return OSLog(subsystem: subsystem, category: filename)
    }
    
    /// Format message with optional context
    private static func formatMessage(_ message: String, file: String = #file, function: String = #function, line: Int = #line) -> String {
        guard includeContext else { return message }
        let filename = (file as NSString).lastPathComponent
        return "[\(filename):\(line)] \(message)"
    }
    
    // MARK: - Public Logging API
    
    /// Log debug-level messages (development only)
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let log = logger(for: file)
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        os_log(.debug, log: log, "%{public}@", formattedMessage)
    }
    
    /// Log info-level messages (general operational information)
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let log = logger(for: file)
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        os_log(.info, log: log, "%{public}@", formattedMessage)
    }
    
    /// Log error-level messages (recoverable errors)
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let log = logger(for: file)
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        os_log(.error, log: log, "%{public}@", formattedMessage)
    }
    
    /// Log fault-level messages (critical failures, crashes)
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (auto-populated)
    ///   - function: Function name (auto-populated)
    ///   - line: Line number (auto-populated)
    static func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let log = logger(for: file)
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        os_log(.fault, log: log, "%{public}@", formattedMessage)
    }
    
    // MARK: - Convenience Methods for Common Operations
    
    /// Log API request details
    static func logAPIRequest(_ endpoint: String, apiKeyPrefix: String = "") {
        let maskedKey = apiKeyPrefix.isEmpty ? "no key" : "\(apiKeyPrefix)..."
        info("API Request: \(endpoint) | Key: \(maskedKey)")
    }
    
    /// Log API response details
    static func logAPIResponse(_ statusCode: Int, durationMs: Int) {
        let level: OSLogType = statusCode >= 400 ? .error : .info
        let log = logger(for: #file)
        os_log(level, log: log, "API Response: status=%d duration=%dms", statusCode, durationMs)
    }
    
    /// Log error with context
    static func logError(_ error: Error, context: String = "") {
        let contextPrefix = context.isEmpty ? "" : "\(context) | "
        error("\(contextPrefix)Error: \(error.localizedDescription)")
    }
    
    /// Log usage data refresh
    static func logUsageRefresh(used: Int, total: Int, percentage: Double) {
        debug("Usage refresh: \(used)/\(total) (\(Int(percentage * 100))%)")
    }
    
    /// Log keychain operation
    static func logKeychainOperation(_ operation: String, success: Bool) {
        let result = success ? "success" : "failed"
        info("Keychain \(operation): \(result)")
    }
}

// MARK: - Logger Convenience Alias
/// Shortcut for using the logger
let logger = AppLogger.self
