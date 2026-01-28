import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var usageMonitor: UsageMonitor
    @State private var refreshInterval: Double = 60
    @State private var saveStatus: SaveStatus = .idle
    let onBack: () -> Void

    enum SaveStatus: Equatable {
        case idle
        case saving
        case saved
        case error(String)

        static func == (lhs: SaveStatus, rhs: SaveStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.saving, .saving), (.saved, .saved):
                return true
            case (.error(let lhsMsg), .error(let rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            settingsHeader
            apiKeySection
            refreshSection
            refreshButton
            quitButton
            statusMessage
        }
        .padding()
        .onAppear {
            loadSettings()
        }
    }

    private var settingsHeader: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                GlassCard()
                    .frame(width: 32, height: 32)
            )

            Spacer()
        }
        .padding(.bottom, 8)
    }

    private var apiKeySection: some View {
        HStack(spacing: 12) {
            currentKeyInfo
            changeKeyButton
        }
        .frame(height: 60)
    }

    private var currentKeyInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("API Key")
                .font(.caption.weight(.medium))
                .foregroundColor(.white.opacity(0.6))

            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.cyan)

                Text("Configured")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.cyan)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.cyan.opacity(0.1))
        )
    }

    private var changeKeyButton: some View {
        Button(action: openKeySetup) {
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Change")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(.white)
            }
        }
        .frame(width: 80)
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Refresh Interval")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("\(Int(refreshInterval))s")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Slider(
                value: $refreshInterval,
                in: 10...300,
                step: 10
            )
            .tint(.white.opacity(0.8))
            .onChange(of: refreshInterval) { _ in
                Settings.shared.refreshInterval = refreshInterval
            }
        }
    }

    private var refreshButton: some View {
        Button(action: {
            Task {
                await usageMonitor.refresh()
            }
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh Now")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var quitButton: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            HStack {
                Image(systemName: "xmark.circle")
                Text("Quit App")
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var statusMessage: some View {
        Group {
            switch saveStatus {
            case .saved:
                Text("Settings saved successfully!")
                    .font(.caption)
                    .foregroundColor(.green)
            case .error(let message):
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: saveStatus)
    }

    private func loadSettings() {
        refreshInterval = Settings.shared.refreshInterval
    }

    private func openKeySetup() {
        // Clear the API key to trigger first-launch flow
        Settings.shared.clear()
        do {
            try KeychainService.shared.delete()
        } catch {
            print("Failed to delete key from keychain: \(error)")
        }

        // Close the popover
        NSApp.windows.filter { $0.isVisible && $0.title.isEmpty }.first?.close()

        // Post notification to reopen setup
        NotificationCenter.default.post(name: Notification.Name("openAPIKeySetup"), object: nil)
    }
}

#Preview {
    SettingsView(onBack: {})
        .environmentObject(UsageMonitor())
}
