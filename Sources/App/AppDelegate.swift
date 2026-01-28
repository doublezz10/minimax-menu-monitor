import SwiftUI
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var usageMonitor: UsageMonitor?
    private var cancellables = Set<AnyCancellable>()
    private var statusBar: NSStatusBar?
    private var contextMenu: NSMenu!

    // URLs for context menu actions
    // Update these URLs when forking the repository
    private let githubIssuesURL = URL(string: "https://github.com/doublezz10/minimax-menu-monitor/issues")!
    private let minimaxUsageURL = URL(string: "https://platform.minimax.io/user-center/payment/coding-plan")!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupContextMenu()
        setupUsageMonitor()
        setupStatusItem()
        setupPopover()
        setupNotifications()
    }

    private func setupContextMenu() {
        contextMenu = NSMenu()

        let reportIssueItem = NSMenuItem(title: "Report Issue", action: #selector(reportIssue), keyEquivalent: "")
        reportIssueItem.target = self

        let viewUsageItem = NSMenuItem(title: "View MiniMax Usage", action: #selector(viewUsage), keyEquivalent: "")
        viewUsageItem.target = self

        let dividerItem = NSMenuItem.separator()

        let quitItem = NSMenuItem(title: "Quit App", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self

        contextMenu.addItem(reportIssueItem)
        contextMenu.addItem(viewUsageItem)
        contextMenu.addItem(dividerItem)
        contextMenu.addItem(quitItem)
    }

    @objc private func reportIssue() {
        NSWorkspace.shared.open(githubIssuesURL)
    }

    @objc private func viewUsage() {
        NSWorkspace.shared.open(minimaxUsageURL)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
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
        window.styleMask = NSWindow.StyleMask([.titled, .closable])
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
        statusItem?.button?.menu = contextMenu
    }

    private func setupPopover() {
        guard let monitor = usageMonitor else { return }
        
        let contentView = ContentView()
            .environmentObject(monitor)
        
        let controller = NSHostingController(rootView: contentView)
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 450)
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

        // Apple-native design: thin ring without heavy black border
        // Subtle shadow provides contrast on all backgrounds

        // Background circle (subtle, adaptive)
        let backgroundCircle = NSBezierPath(ovalIn: NSRect(x: 1, y: 1, width: 16, height: 16))
        NSColor.white.withAlphaComponent(0.15).setFill()
        backgroundCircle.fill()

        // Usage arc (thin ring, Apple-style)
        // Using arc instead of pie slice for cleaner look
        let radius: CGFloat = 7
        let center = NSPoint(x: 9, y: 9)

        // Background ring (track)
        let trackCircle = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        NSColor.white.withAlphaComponent(0.2).setStroke()
        trackCircle.lineWidth = 1.5
        trackCircle.stroke()

        // Usage arc (fills clockwise from top)
        if percentage > 0 {
            let startAngle: CGFloat = -90  // Top (12 o'clock)
            let endAngle: CGFloat = -90 + (360 * CGFloat(percentage))

            let usageArc = NSBezierPath()
            usageArc.appendArc(
                withCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            usageArc.lineWidth = 1.5
            usageArc.lineCapStyle = .round

            // Color based on usage level (subtle neon palette)
            let color: NSColor
            if percentage < 0.5 {
                // Low usage: subtle cyan/teal
                color = NSColor(red: 0.0, green: 0.8, blue: 0.7, alpha: 0.85)
            } else if percentage < 0.8 {
                // Medium usage: subtle amber
                color = NSColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.85)
            } else {
                // High usage: subtle coral/red
                color = NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 0.85)
            }

            color.setStroke()
            usageArc.stroke()
        }

        // Loading indicator: SF Symbol-style rotation arrow
        if isLoading {
            let loadingPath = NSBezierPath()
            // Draw a small circular arrow
            let arrowCenter = NSPoint(x: 9, y: 9)
            let arrowRadius: CGFloat = 4

            // Arc portion
            loadingPath.appendArc(
                withCenter: arrowCenter,
                radius: arrowRadius,
                startAngle: 45,
                endAngle: 315,
                clockwise: true
            )

            // Arrow head
            let arrowHeadSize: CGFloat = 2.5
            let headPoint = NSPoint(
                x: arrowCenter.x + arrowRadius * cos(.pi / 4),
                y: arrowCenter.y + arrowRadius * sin(.pi / 4)
            )

            loadingPath.move(to: NSPoint(x: headPoint.x - arrowHeadSize, y: headPoint.y - arrowHeadSize))
            loadingPath.line(to: headPoint)
            loadingPath.line(to: NSPoint(x: headPoint.x - arrowHeadSize, y: headPoint.y + arrowHeadSize))

            NSColor.white.withAlphaComponent(0.7).setStroke()
            loadingPath.lineWidth = 1
            loadingPath.stroke()
        }

        image.unlockFocus()

        // Enable template mode for proper dark/light adaptation
        image.isTemplate = true

        return image
    }
}
