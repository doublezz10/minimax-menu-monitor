import SwiftUI

@main
struct MinimaxMenuMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = Settings.shared
    @State private var setupWindow: NSWindow?

    var body: some Scene {
        WindowGroup {
            if settings.apiKey.isEmpty {
                FirstLaunchView()
            } else {
                Text("")
                    .frame(width: 0, height: 0)
                    .hidden()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct FirstLaunchView: View {
    @EnvironmentObject var usageMonitor: UsageMonitor
    @State private var apiKey: String = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    // URLs
    private let githubIssuesURL = URL(string: "https://github.com/doublezz10/minimax-menu-monitor/issues")!
    private let minimaxUsageURL = URL(string: "https://platform.minimax.io/user-center/payment/coding-plan")!

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo/Icon
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("MiniMax Menu Monitor")
                .font(.title.weight(.bold))
                .foregroundColor(.white)

            Text("Enter your API key to get started")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            // API Key input
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.8))

                SecureField("sk-...", text: $apiKey)
                    .textFieldStyle(CustomTextFieldStyle())
                    .disabled(isValidating)
            }
            .padding(.horizontal, 40)

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }

            // Success message
            if showSuccess {
                Label("API Key Saved!", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 40)
            }

            // Continue button
            Button(action: saveAndContinue) {
                HStack {
                    if isValidating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.right")
                    }
                    Text(isValidating ? "Validating..." : "Continue")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(apiKey.isEmpty || isValidating)
            .padding(.horizontal, 40)
            .padding(.top, 16)

            Spacer()

            // Footer with links
            VStack(spacing: 8) {
                HStack(spacing: 24) {
                    LinkButton(
                        title: "Report Issue",
                        url: githubIssuesURL,
                        icon: "exclamationmark.bubble"
                    )

                    LinkButton(
                        title: "View Usage",
                        url: minimaxUsageURL,
                        icon: "chart.bar"
                    )
                }

                Text("Your API key is stored securely in macOS Keychain")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(white: 0.1), Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func saveAndContinue() {
        isValidating = true
        errorMessage = nil

        // Save API key
        Settings.shared.apiKey = apiKey

        // Save to keychain
        do {
            try KeychainService.shared.save(key: apiKey)
            isValidating = false
            showSuccess = true

            // Close window after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NSApp.windows.first?.close()
            }
        } catch {
            isValidating = false
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }
    }
}

struct LinkButton: View {
    let title: String
    let url: URL
    let icon: String

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}
