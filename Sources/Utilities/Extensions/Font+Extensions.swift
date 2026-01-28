import SwiftUI

// MARK: - Typography System
// Consistent font sizes and weights for clear visual hierarchy

enum AppFont {
    // MARK: - Display (Large headers, hero text)
    static let display = Font.system(size: 32, weight: .bold, design: .rounded)

    // MARK: - Title (Section headers, modal titles)
    static let title = Font.system(size: 24, weight: .bold, design: .rounded)

    // MARK: - Heading (Subsection headers, card titles)
    static let heading = Font.system(size: 18, weight: .bold, design: .rounded)

    // MARK: - Subhead (Component titles, emphasis text)
    static let subhead = Font.system(size: 16, weight: .semibold, design: .rounded)

    // MARK: - Body (Primary content text)
    static let body = Font.system(size: 14, weight: .regular, design: .rounded)

    // MARK: - Caption (Secondary text, labels, metadata)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)

    // MARK: - Small (Fine print, timestamps, legal text)
    static let small = Font.system(size: 10, weight: .regular, design: .rounded)

    // MARK: - Monospace (Numbers, data, usage stats)
    static let monospace = Font.system(size: 14, weight: .medium, design: .monospaced)
}

// MARK: - Legacy Support
// Keep neon() for backward compatibility during migration

extension Font {
    /// Legacy font function - migrate to AppFont enum
    /// @deprecated Use AppFont.display, AppFont.title, etc. instead
    static func neon(size: CGFloat = 24) -> Font {
        Font.system(size: size, weight: .bold, design: .rounded)
    }
}
