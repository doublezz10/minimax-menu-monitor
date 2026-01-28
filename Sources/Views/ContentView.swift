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
        HStack(spacing: 0) {
            // Left: MMM logo
            HStack(spacing: 3) {
                Text("M")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.neonCyan)
                Text("M")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.neonPurple)
                Text("M")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.neonBlue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("App logo: M M M")
            
            // Center: Model indicator - always visible with same sizing
            HStack(spacing: 4) {
                Image(systemName: "cpu")
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
                if let modelName = usageMonitor.usageData?.modelName {
                    Text(modelName)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                } else {
                    Text("No data")
                        .font(.caption2)
                        .foregroundColor(.textTertiary.opacity(0.5))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
            .accessibilityLabel("Model: \(usageMonitor.usageData?.modelName ?? "Unknown")")
            
            Spacer()
            
            // Right: Settings button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showSettings.toggle()
                }
            }) {
                Image(systemName: showSettings ? "chart.bar.fill" : "gearshape.fill")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
            )
            .accessibilityLabel(showSettings ? "Usage view" : "Settings")
            .accessibilityHint(showSettings ? "Shows usage information" : "Opens settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
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
