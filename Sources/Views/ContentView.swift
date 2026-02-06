import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usageMonitor: UsageMonitor
    @State private var showSettings = false

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                contentArea
            }
        }
        .frame(width: 300)
        .onAppear {
            // Show settings by default if no API key is configured
            showSettings = !usageMonitor.hasValidKey
        }
    }

    private var headerView: some View {
        HStack(spacing: 6) {
            // Left: App icon - elegant single icon
            Image(systemName: "chart.bar.fill")
                .font(AppFont.small)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.neonCyan, .neonPurple, .neonBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.cardBackground)
                )
                .accessibilityLabel("MiniMax Menu Monitor")
            
            // Center: Model indicator
            HStack(spacing: 2) {
                Image(systemName: "cpu")
                    .font(AppFont.small)
                    .foregroundColor(.textTertiary)
                if let modelName = usageMonitor.usageData?.modelName {
                    Text(modelName)
                        .font(AppFont.small.weight(.medium))
                        .foregroundColor(.textTertiary)
                } else {
                    Text("—")
                        .font(AppFont.small)
                        .foregroundColor(.textTertiary.opacity(0.5))
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
            .accessibilityLabel("Model: \(usageMonitor.usageData?.modelName ?? "Unknown")")
            
            Spacer()
            
            // Right: Settings button
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    showSettings.toggle()
                }
            }) {
                Image(systemName: showSettings ? "chart.bar.fill" : "gearshape.fill")
                    .font(AppFont.small)
                    .foregroundColor(.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
            .accessibilityLabel(showSettings ? "Usage view" : "Settings")
            .accessibilityHint(showSettings ? "Shows usage information" : "Opens settings")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
    }

    private var contentArea: some View {
        VStack(spacing: 0) {
            // Divider between header and content
            Rectangle()
                .fill(Color.glassBorder)
                .frame(height: 1)
            
            // Content with smooth transition
            Group {
                if showSettings {
                    SettingsView(onBack: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showSettings = false
                        }
                    })
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSettings)
                } else {
                    UsageView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSettings)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UsageMonitor())
}
