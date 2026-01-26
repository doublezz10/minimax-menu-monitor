import SwiftUI
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var usageMonitor: UsageMonitor?
    private var cancellables = Set<AnyCancellable>()
    private var statusBar: NSStatusBar?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupUsageMonitor()
        setupStatusItem()
        setupPopover()
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("openAPIKeySetup"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.openSetupWindow()
        }
    }

    private func openSetupWindow() {
        let setupView = FirstLaunchView()
        let hostingController = NSHostingController(rootView: setupView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "MiniMax Menu Monitor"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func setupStatusItem() {
        statusBar = NSStatusBar.system
        statusItem = statusBar?.statusItem(withLength: -1)
        statusItem?.button?.image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "MiniMax Usage")
        statusItem?.button?.image?.size = NSSize(width: 18, height: 18)
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.action = #selector(togglePopover)
        statusItem?.button?.target = self
    }

    private func setupPopover() {
        guard let monitor = usageMonitor else { return }
        
        let contentView = ContentView()
            .environmentObject(monitor)
        
        let controller = NSHostingController(rootView: contentView)
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.contentViewController = controller
        popover?.behavior = .transient
        popover?.animates = true
    }

    private func setupUsageMonitor() {
        usageMonitor = UsageMonitor()
        usageMonitor?.startMonitoring()

        usageMonitor?.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateStatusIcon(isLoading: isLoading)
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        if popover?.isShown == true {
            popover?.perform(#selector(NSPopover.close), with: nil, afterDelay: 0)
        } else {
            if let button = statusItem?.button {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    private func updateStatusIcon(isLoading: Bool) {
        // Dynamic icon based on usage
        if let monitor = usageMonitor {
            let percentage = monitor.usagePercentage
            let usageIcon = createUsageIcon(percentage: percentage, isLoading: isLoading)
            statusItem?.button?.image = usageIcon
        } else {
            let iconName = isLoading ? "chart.bar" : "chart.bar.fill"
            statusItem?.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "MiniMax Usage")
        }
    }

    private func createUsageIcon(percentage: Double, isLoading: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Background circle (semi-transparent)
        let backgroundCircle = NSBezierPath(ovalIn: NSRect(x: 1, y: 1, width: 16, height: 16))
        NSColor.white.withAlphaComponent(0.3).setFill()
        backgroundCircle.fill()
        
        // Usage circle (fills based on percentage)
        let usageAngle = 90 - (360 * percentage)
        let usageCircle = NSBezierPath()
        usageCircle.move(to: NSPoint(x: 9, y: 9))
        usageCircle.appendArc(
            withCenter: NSPoint(x: 9, y: 9),
            radius: 8,
            startAngle: 90,
            endAngle: usageAngle,
            clockwise: true
        )
        usageCircle.close()
        
        // Color based on usage (white -> yellow -> red)
        let color: NSColor
        if percentage < 0.5 {
            color = .white
        } else if percentage < 0.8 {
            color = .systemYellow
        } else {
            color = .systemRed
        }
        
        color.withAlphaComponent(0.8).setFill()
        usageCircle.fill()
        
        // Loading indicator
        if isLoading {
            let loadingCircle = NSBezierPath(ovalIn: NSRect(x: 3, y: 3, width: 12, height: 12))
            NSColor.white.withAlphaComponent(0.5).setStroke()
            loadingCircle.lineWidth = 1
            loadingCircle.stroke()
        }
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}
