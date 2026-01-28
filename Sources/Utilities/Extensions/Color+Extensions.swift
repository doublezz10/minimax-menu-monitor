import SwiftUI

// MARK: - Color System
// Organized palette for consistent design language

// MARK: - Brand Colors (Neon Palette)
// Primary brand colors for branding and accents

extension Color {
    static let neonCyan = Color(red: 0.0, green: 1.0, blue: 0.8)
    static let neonPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
    static let neonBlue = Color(red: 0.2, green: 0.4, blue: 1.0)
}

// MARK: - Semantic Colors
// Status and feedback colors

extension Color {
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red

    // Brand gradient for primary buttons
    static let primaryGradient = LinearGradient(
        colors: [neonPurple, neonBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Glassmorphism Colors
// Translucent UI elements for the glass effect

extension Color {
    static let glassBackground = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.2)
    static let glassHighlight = Color.white.opacity(0.05)
    static let glassWhite = Color.white.opacity(0.2)
}

// MARK: - UI Element Colors
// Backgrounds, surfaces, and interactive states

extension Color {
    static let cardBackground = Color.white.opacity(0.08)
    static let hoverBackground = Color.white.opacity(0.15)
    static let activeBackground = Color.white.opacity(0.25)
}

// MARK: - Text Hierarchy
// Consistent text colors for visual hierarchy

extension Color {
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let textTertiary = Color.white.opacity(0.6)
    static let textDisabled = Color.white.opacity(0.3)
}

// MARK: - Usage Indicator Colors
// Color coding for usage percentage levels

extension Color {
    static let usageLow = neonCyan          // 0-50%
    static let usageMedium = Color.yellow   // 50-80%
    static let usageHigh = Color.red        // 80-100%
}

// MARK: - Legacy Support
// Keep original names for backward compatibility

extension Color {
    @available(*, deprecated, renamed: "glassWhite")
    static let legacyGlassWhite = glassWhite

    @available(*, deprecated, renamed: "glassBorder")
    static let legacyGlassBorder = glassBorder
}

// MARK: - View Extensions
// Convenience modifiers for common visual effects

extension View {
    /// Apply a glow effect with specified color and radius
    func glow(color: Color = .cyan, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.8), radius: radius, x: 0, y: 0)
    }

    /// Apply the signature neon cyan glow effect
    func neonGlow() -> some View {
        self.shadow(color: .neonCyan.opacity(0.8), radius: 15, x: 0, y: 5)
    }
}
