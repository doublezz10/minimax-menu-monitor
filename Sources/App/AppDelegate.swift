import SwiftUI
import Combine

// Custom view to handle both left and right clicks on status item
class StatusItemButtonView: NSView {
    var onLeftClick: (() -> Void)?
    var onRightClick: (() -> Void)?
    var image: NSImage? {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if let image = image {
            let iconSize = NSSize(width: 18, height: 18)
            let imageRect = NSRect(
                x: (dirtyRect.width - iconSize.width) / 2,
                y: (dirtyRect.height - iconSize.height) / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            image.draw(in: imageRect)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.type == .rightMouseDown {
            onRightClick?()
        } else {
            onLeftClick?()
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var usageMonitor: UsageMonitor?
    private var cancellables = Set<AnyCancellable>()
    private var statusBar: NSStatusBar?
    private var customButton: StatusItemButtonView?
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
    }

    private func setupContextMenu() {
        contextMenu = NSMenu()
        
        // Report Issue - no shortcut
        let reportIssueItem = NSMenuItem(title: "Report Issue", action: #selector(reportIssue), keyEquivalent: "")
        reportIssueItem.target = self
        
        // View MiniMax Usage - no shortcut (opens external site)
        let viewUsageItem = NSMenuItem(title: "View MiniMax Usage", action: #selector(viewUsage), keyEquivalent: "")
        viewUsageItem.target = self
        
        // Divider
        let dividerItem = NSMenuItem.separator()
        
        // Refresh - Cmd+R
        let refreshItem = NSMenuItem(title: "Refresh Usage", action: #selector(refreshUsage), keyEquivalent: "r")
        refreshItem.keyEquivalentModifierMask = [.command]
        refreshItem.target = self
        
        // Divider
        let dividerItem2 = NSMenuItem.separator()
        
        // Quit - Cmd+Q (standard macOS shortcut)
        let quitItem = NSMenuItem(title: "Quit App", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        
        contextMenu.addItem(reportIssueItem)
        contextMenu.addItem(viewUsageItem)
        contextMenu.addItem(dividerItem)
        contextMenu.addItem(refreshItem)
        contextMenu.addItem(dividerItem2)
        contextMenu.addItem(quitItem)
    }
    
    @objc private func refreshUsage() {
        NotificationCenter.default.post(name: Notification.Name("refreshUsage"), object: nil)
    }
    
    @objc private func openSettings() {
        // Post notification to open settings view
        NotificationCenter.default.post(name: Notification.Name("openSettings"), object: nil)
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

    private func setupStatusItem() {
        statusBar = NSStatusBar.system
        statusItem = statusBar?.statusItem(withLength: -1)
        
        // Create custom button view for proper left/right click handling
        let buttonView = StatusItemButtonView()
        buttonView.onLeftClick = { [weak self] in
            self?.togglePopover()
        }
        buttonView.onRightClick = { [weak self] in
            guard let self = self else { return }
            // Use current mouse location for context menu
            let mouseLocation = NSEvent.mouseLocation
            self.contextMenu.popUp(positioning: nil, at: mouseLocation, in: nil)
        }
        
        // Set up status item with custom view
        statusItem?.view = buttonView
        statusItem?.button?.image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "MiniMax Usage")
        statusItem?.button?.image?.size = NSSize(width: 18, height: 18)
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.menu = contextMenu
        
        // Update custom button with image
        let image = NSImage(systemSymbolName: "chart.bar.fill", accessibilityDescription: "MiniMax Usage")
        image?.size = NSSize(width: 18, height: 18)
        image?.isTemplate = true
        buttonView.image = image
        customButton = buttonView
    }

    private func setupPopover() {
        guard let monitor = usageMonitor else { return }
        
        let contentView = ContentView()
            .environmentObject(monitor)
        
        let controller = NSHostingController(rootView: contentView)
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 280)
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
