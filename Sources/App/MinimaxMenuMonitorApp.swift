import SwiftUI

@main
struct MinimaxMenuMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app - no WindowGroup needed
        // All UI is handled via NSPopover in AppDelegate
    }
}
