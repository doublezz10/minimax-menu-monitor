import SwiftUI

@main
struct MinimaxMenuMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = Settings.shared

    var body: some Scene {
        WindowGroup {
            Text("")
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
    }
}
