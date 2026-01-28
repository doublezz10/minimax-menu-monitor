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
        VStack(spacing: 12) {
            apiKeySection
            refreshSection
            refreshButton
            linksSection
            quitButton
            Spacer()
            statusMessage
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            loadSettings()
        }
    }
    
    private let githubIssuesURL = URL(string: "https://github.com/doublezz10/minimax-menu-monitor/issues")!
    private let minimaxUsageURL = URL(string: "https://platform.minimax.io/user-center/payment/coding-plan")!
    
    private var linksSection: some View {
        HStack(spacing: 16) {
            Link(destination: githubIssuesURL) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.bubble")
                    Text("Report Issue")
                }
                .font(.caption)
                .foregroundColor(.textTertiary)
            }
            
            Link(destination: minimaxUsageURL) {
                HStack(spacing: 4) {
                    Image(systemName: "creditcard")
                    Text("Manage Subscription")
                }
                .font(.caption)
                .foregroundColor(.textTertiary)
            }
        }
        .padding(.top, 4)
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
                .font(.caption)
                .foregroundColor(.textTertiary)

            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.neonCyan)

                Text("Configured")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.neonCyan)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.neonCyan.opacity(0.1))
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
                .foregroundColor(.textPrimary)
            }
        }
        .frame(width: 80)
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Refresh Interval")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(Int(refreshInterval))s")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            Slider(
                value: $refreshInterval,
                in: 10...300,
                step: 10
            )
            .tint(.textPrimary.opacity(0.8))
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
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.neonPurple, Color.neonBlue],
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
            .foregroundColor(.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.glassBorder, lineWidth: 1)
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
                    .foregroundColor(.success)
            case .error(let message):
                Text(message)
                    .font(.caption)
                    .foregroundColor(.error)
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
    }
}

#Preview {
    SettingsView(onBack: {})
        .environmentObject(UsageMonitor())
}
