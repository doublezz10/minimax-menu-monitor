import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var usageMonitor: UsageMonitor
    @State private var refreshInterval: Double = 60
    @State private var saveStatus: SaveStatus = .idle
    @State private var showingChangeKeyPopout = false
    @State private var newApiKey = ""
    @State private var keyChangeStatus: KeyChangeStatus = .idle
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

    enum KeyChangeStatus: Equatable {
        case idle
        case saving
        case saved
        case error(String)

        static func == (lhs: KeyChangeStatus, rhs: KeyChangeStatus) -> Bool {
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
                .font(AppFont.caption)
                .foregroundColor(.textTertiary)
            }
            
            Link(destination: minimaxUsageURL) {
                HStack(spacing: 4) {
                    Image(systemName: "creditcard")
                    Text("Manage Subscription")
                }
                .font(AppFont.caption)
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
                .font(AppFont.caption)
                .foregroundColor(.textTertiary)

            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.neonCyan)

                Text("Configured")
                    .font(AppFont.caption.weight(.medium))
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
        Button(action: {
            showingChangeKeyPopout = true
            newApiKey = ""
            keyChangeStatus = .idle
        }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Change")
            }
            .font(AppFont.caption.weight(.medium))
            .foregroundColor(.textPrimary)
        }
        .frame(width: 80, height: 60)
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .popover(isPresented: $showingChangeKeyPopout) {
            changeKeyPopout
                .frame(width: 300, height: 180)
        }
    }

    private var changeKeyPopout: some View {
        VStack(spacing: 12) {
            Text("Change API Key")
                .font(.headline)
                .foregroundColor(.textPrimary)

            TextField("Enter new API key", text: $newApiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .disableAutocorrection(true)

            HStack(spacing: 12) {
                Button(action: {
                    showingChangeKeyPopout = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: saveNewApiKey) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newApiKey.isEmpty || keyChangeStatus == .saving)
            }

            Group {
                switch keyChangeStatus {
                case .saved:
                    Text("API key updated successfully!")
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
            .animation(.easeInOut(duration: 0.3), value: keyChangeStatus)
        }
        .padding()
    }

    private func saveNewApiKey() {
        keyChangeStatus = .saving

        do {
            try KeychainService.shared.save(key: newApiKey)
            Settings.shared.apiKey = newApiKey
            keyChangeStatus = .saved

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingChangeKeyPopout = false
                keyChangeStatus = .idle
            }
        } catch {
            keyChangeStatus = .error("Failed to save API key: \(error.localizedDescription)")
        }
    }

    private var refreshSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Refresh")
                    .font(AppFont.caption.weight(.medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(Int(refreshInterval))s")
                    .font(AppFont.caption)
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
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                Text("Refresh")
            }
            .font(AppFont.caption.weight(.medium))
            .foregroundColor(.textPrimary)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.neonPurple, Color.neonBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var quitButton: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            HStack(spacing: 6) {
                Image(systemName: "xmark.circle")
                Text("Quit")
            }
            .font(AppFont.caption.weight(.medium))
            .foregroundColor(.textSecondary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
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
                    .font(AppFont.caption)
                    .foregroundColor(.success)
            case .error(let message):
                Text(message)
                    .font(AppFont.caption)
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
