import SwiftUI

// MARK: - Spacing System
// Consistent spacing tokens for uniform layout throughout the app

struct Spacing {
    // MARK: - Edge Padding
    // General spacing for margins and padding

    static let none: CGFloat = 0
    static let xxs: CGFloat = 4      // Extra extra small
    static let xs: CGFloat = 8       // Extra small
    static let sm: CGFloat = 12      // Small
    static let md: CGFloat = 16      // Medium (base unit)
    static let lg: CGFloat = 24      // Large
    static let xl: CGFloat = 32      // Extra large
    static let xxl: CGFloat = 48     // Extra extra large

    // MARK: - Component Spacing
    // Specific spacing between common UI elements

    static let iconTextGap: CGFloat = 6      // Icon to adjacent text
    static let buttonIconGap: CGFloat = 8    // Icon inside button to text
    static let labelValueGap: CGFloat = 8    // Label to its value
    static let itemSpacing: CGFloat = 12     // Between list items

    // MARK: - Container Padding
    // Padding within containers and cards

    static let cardPadding: CGFloat = 12     // Inside cards, glass views
    static let sectionPadding: CGFloat = 16  // Between major sections
    static let screenPadding: CGFloat = 24   // Main content margins

    // MARK: - Corner Radius
    // Consistent rounded corners

    static let cornerSmall: CGFloat = 6      // Small elements, tags
    static let cornerMedium: CGFloat = 10    // Buttons, cards, inputs
    static let cornerLarge: CGFloat = 16     // Large containers, modals
    static let cornerFull: CGFloat = 1000    // Capsule, circle (clamped)
}

// MARK: - Layout Helpers
// Convenience functions for common layouts

extension View {
    /// Center content with optional max width
    func centered(maxWidth: CGFloat? = nil) -> some View {
        self.frame(maxWidth: maxWidth ?? .infinity)
            .frame(maxWidth: .infinity)
    }

    /// Create uniform spacing between views in an HStack
    func hSpacing(_ spacing: CGFloat = Spacing.md) -> some View {
        self.frame(height: spacing)
    }

    /// Create uniform spacing between views in a VStack
    func vSpacing(_ spacing: CGFloat = Spacing.md) -> some View {
        self.frame(width: spacing)
    }
}
