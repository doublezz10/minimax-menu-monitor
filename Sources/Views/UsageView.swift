import SwiftUI

struct UsageView: View {
    @EnvironmentObject var usageMonitor: UsageMonitor
    @State private var currentTime = Date()

    var body: some View {
        VStack(spacing: 16) {
            if usageMonitor.isLoading && usageMonitor.usageData == nil {
                loadingView
            } else if let error = usageMonitor.error {
                errorView(error)
            } else if usageMonitor.hasValidKey {
                usageDisplay
            } else {
                emptyStateView
            }
        }
        .padding(16)
        .frame(width: 300)
        .onAppear {
            // Update time every second for live countdown
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .textPrimary))
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.warning)

            Text("Error")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textPrimary)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await usageMonitor.refresh()
                }
            }) {
                Text("Retry")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.neonPurple)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    private var usageDisplay: some View {
        VStack(spacing: 12) {
            // Model name
            if let modelName = usageMonitor.usageData?.modelName {
                HStack {
                    Image(systemName: "cpu")
                        .font(.caption)
                        .foregroundColor(.neonCyan)
                    Text(modelName)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.neonCyan)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.neonCyan.opacity(0.15))
                )
            }

            // Compact liquid progress
            LiquidProgressView(
                progress: usageMonitor.usagePercentage,
                remaining: usageMonitor.formattedRemaining,
                total: usageMonitor.formattedTotal
            )
            .frame(height: 100)

            // Usage bar
            usageBar

            // Stats row
            HStack(spacing: 12) {
                compactStat(title: "Used", value: usageMonitor.formattedUsed, icon: "chart.bar.fill", color: .neonPurple)
                compactStat(title: "Left", value: usageMonitor.formattedRemaining, icon: "checkmark.circle.fill", color: .neonCyan)
                compactStat(title: "Total", value: usageMonitor.formattedTotal, icon: "chart.pie.fill", color: .neonBlue)
            }

            // Time remaining
            timeRemainingView
        }
    }

    private var usageBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.textPrimary.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.neonPurple, Color.neonBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * usageMonitor.usagePercentage, height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("\(Int(usageMonitor.usagePercentage * 100))%")
                    .font(AppFont.small.weight(.medium))
                    .foregroundColor(.textTertiary)

                Spacer()

                if let timeRemaining = formattedTimeRemaining {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(AppFont.small)
                        Text(timeRemaining)
                    }
                    .font(AppFont.small.weight(.medium).monospacedDigit())
                    .foregroundColor(.neonCyan)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func compactStat(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)

            Text(value)
                .font(.body.weight(.bold))
                .foregroundColor(.textPrimary)

            Text(title)
                .font(AppFont.small)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
        )
    }

    private var timeRemainingView: some View {
        HStack {
            Image(systemName: "clock.fill")
                .font(AppFont.small)
                .foregroundColor(.neonCyan)

            Text("Resets in: \(formattedTimeRemaining ?? "—")")
                .font(AppFont.small.weight(.medium).monospacedDigit())
                .foregroundColor(.textSecondary)

            Spacer()

            Text(intervalEndDescription)
                .font(AppFont.small)
                .foregroundColor(.textTertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.neonCyan.opacity(0.1))
        )
    }

    private var formattedTimeRemaining: String? {
        guard let remainingSeconds = usageMonitor.usageData?.remainingTimeSeconds,
              remainingSeconds > 0 else { return nil }

        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private var intervalEndDescription: String {
        guard let endTimeMs = usageMonitor.usageData?.endTimeMs else { return "" }

        let endDate = Date(timeIntervalSince1970: Double(endTimeMs) / 1000.0)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current

        return "@ \(formatter.string(from: endDate))"
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.title)
                .foregroundColor(.textTertiary)

            Text("No API Key")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.textPrimary)

            Text("Add your key in settings")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
    }
}

#Preview {
    UsageView()
        .environmentObject(UsageMonitor())
}
