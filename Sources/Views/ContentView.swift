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
                    SettingsView(onBack: { showSettings = false })
                } else {
                    UsageView()
                }
            }
        }
        .frame(width: 320, height: 450)
        .onAppear {
            showSettings = false
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button(action: { showSettings.toggle() }) {
                Image(systemName: showSettings ? "chart.bar.fill" : "gearshape.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(UsageMonitor())
}
