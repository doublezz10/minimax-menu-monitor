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

    var body: some View {
        VStack(spacing: 32) {
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

            // Footer
            Text("Your API key is stored securely in macOS Keychain")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}
