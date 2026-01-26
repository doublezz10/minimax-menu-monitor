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
                Divider()
                    .background(Color.white.opacity(0.2))
                if showSettings {
                    SettingsView()
                } else {
                    UsageView()
                }
            }
        }
        .frame(width: 320, height: showSettings ? 450 : 400)
        .onAppear {
            // Reset to usage view when popover appears
            showSettings = false
        }
    }

    private var headerView: some View {
        HStack {
            Text("MiniMax Usage")
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            Button(action: { showSettings.toggle() }) {
                Image(systemName: showSettings ? "chart.bar.fill" : "gearshape.fill")
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                GlassCard()
                    .frame(width: 32, height: 32)
            )
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(UsageMonitor())
}
