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
            } else if usageMonitor.hasValidKey || Settings.shared.demoMode {
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
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)

            Text("Error")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await usageMonitor.refresh()
                }
            }) {
                Text("Retry")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    private var usageDisplay: some View {
        VStack(spacing: 12) {
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
                compactStat(title: "Used", value: usageUsed, icon: "chart.bar.fill", color: .purple)
                compactStat(title: "Left", value: usageMonitor.formattedRemaining, icon: "checkmark.circle.fill", color: .cyan)
                compactStat(title: "Total", value: usageMonitor.formattedTotal, icon: "chart.pie.fill", color: .blue)
            }

            // Reset time
            resetTimeView
        }
    }

    private var usageBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
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
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                if let timeRemaining = timeUntilReset {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text(timeRemaining)
                    }
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func compactStat(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var resetTimeView: some View {
        HStack {
            Image(systemName: "arrow.clockwise")
                .font(.caption2)
                .foregroundColor(.cyan)

            Text("Resets in: \(timeUntilReset ?? "—")")
                .font(.caption2.weight(.medium).monospacedDigit())
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(resetTimeDescription)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.cyan.opacity(0.1))
        )
    }

    private var timeUntilReset: String? {
        // MiniMax quota resets at 00:00, 05:00, 10:00, 15:00, 20:00 UTC
        let calendar = Calendar.current
        let now = currentTime // Use the live time state

        // Get current UTC time
        let utcTimezone = TimeZone(identifier: "UTC")!
        var utcComponents = calendar.dateComponents(in: utcTimezone, from: now)
        guard let utcHour = utcComponents.hour,
              let utcMinute = utcComponents.minute else { return nil }

        // Reset hours: 00:00, 05:00, 10:00, 15:00, 20:00 UTC
        let resetHours = [0, 5, 10, 15, 20]

        // Find the next reset time
        var nextResetHour = resetHours.first { $0 > utcHour } ?? resetHours[0]

        // If we've passed the last reset today (20:00), next reset is tomorrow at 00:00
        var nextResetComponents = utcComponents
        nextResetComponents.hour = nextResetHour
        nextResetComponents.minute = 0
        nextResetComponents.second = 0

        if nextResetHour <= utcHour {
            // Next reset is tomorrow
            nextResetComponents.day = (utcComponents.day ?? 0) + 1
        }

        guard let nextReset = calendar.date(from: nextResetComponents),
              let nextResetUTC = calendar.date(from: calendar.dateComponents(in: utcTimezone, from: nextReset)) else {
            return nil
        }

        let timeInterval = nextResetUTC.timeIntervalSince(now)

        if timeInterval <= 0 {
            return "0h 0m"
        }

        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    private var resetTimeDescription: String {
        let calendar = Calendar.current
        let now = currentTime

        let utcTimezone = TimeZone(identifier: "UTC")!
        var utcComponents = calendar.dateComponents(in: utcTimezone, from: now)
        guard let utcHour = utcComponents.hour else { return "" }

        // Reset hours: 00:00, 05:00, 10:00, 15:00, 20:00 UTC
        let resetHours = [0, 5, 10, 15, 20]

        // Find the next reset hour
        let nextResetHour = resetHours.first { $0 > utcHour } ?? resetHours[0]

        if nextResetHour <= utcHour {
            // Next reset is tomorrow at 00:00 UTC
            return "@ 00:00 UTC"
        } else {
            return "@ \(String(format: "%02d:00 UTC", nextResetHour))"
        }
    }

    private var usageUsed: String {
        guard let data = usageMonitor.usageData else { return "—" }
        let used = data.total - data.remains
        return formatNumber(used)
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        } else {
            return "\(number)"
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.6))

            Text("No API Key")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)

            Text("Add your key in settings")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
}

#Preview {
    UsageView()
        .environmentObject(UsageMonitor())
}
