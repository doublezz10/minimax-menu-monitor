import SwiftUI

// MARK: - Button Styles
// Consistent button styles for uniform UI across the app

// MARK: - AppButtonStyle
// Primary button style with variant support

struct AppButtonStyle: ButtonStyle {
    enum Variant {
        case primary      // Gradient fill (purple → blue)
        case secondary    // Outlined with border
        case ghost        // No background, just icon/text
        case danger       // Red filled button
    }

    let variant: Variant
    let isEnabled: Bool

    init(variant: Variant = .primary, isEnabled: Bool = true) {
        self.variant = variant
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(foregroundColor(for: configuration.isPressed))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(background(for: configuration.isPressed))
            .cornerRadius(Spacing.cornerMedium)
            .opacity(isEnabled ? 1.0 : 0.5)
    }

    private func foregroundColor(for isPressed: Bool) -> Color {
        switch variant {
        case .primary, .danger:
            return .white
        case .secondary, .ghost:
            return isPressed ? .textSecondary : .textPrimary
        }
    }

    private func background(for isPressed: Bool) -> some View {
        Group {
            switch variant {
            case .primary:
                LinearGradient(
                    colors: isPressed ? [Color.neonPurple.opacity(0.8), Color.neonBlue.opacity(0.8)] : [Color.neonPurple, Color.neonBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )

            case .secondary:
                RoundedRectangle(cornerRadius: Spacing.cornerMedium)
                    .stroke(Color.glassBorder, lineWidth: 1)
                    .background(isPressed ? Color.hoverBackground : Color.clear)

            case .ghost:
                Color.clear

            case .danger:
                LinearGradient(
                    colors: isPressed ? [Color.red.opacity(0.7), Color.orange.opacity(0.7)] : [Color.red, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
}

// MARK: - ButtonStyle Convenience Extension

extension ButtonStyle where Self == AppButtonStyle {
    /// Create an app-style button with specified variant
    /// - Parameters:
    ///   - variant: Button style variant (default: .primary)
    ///   - isEnabled: Whether button is enabled (default: true)
    /// - Returns: Configured AppButtonStyle
    static func app(variant: AppButtonStyle.Variant = .primary, isEnabled: Bool = true) -> AppButtonStyle {
        AppButtonStyle(variant: variant, isEnabled: isEnabled)
    }
}

// MARK: - AppIconButtonStyle
// Icon-only button style for toolbar items

struct AppIconButtonStyle: ButtonStyle {
    let size: CGFloat
    let showBackground: Bool

    init(size: CGFloat = 32, showBackground: Bool = false) {
        self.size = size
        self.showBackground = showBackground
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .foregroundColor(configuration.isPressed ? .textSecondary : .textPrimary)
            .background(
                Group {
                    if showBackground {
                        Circle()
                            .fill(configuration.isPressed ? Color.hoverBackground : Color.glassBackground)
                    }
                }
            )
    }
}

// MARK: - IconButtonStyle Convenience Extension

extension ButtonStyle where Self == AppIconButtonStyle {
    /// Create an icon-only button with default 32x32 size
    static var appIcon: AppIconButtonStyle { AppIconButtonStyle() }

    /// Create an icon-only button with custom size
    /// - Parameter size: Button size (default: 32)
    /// - Returns: Configured AppIconButtonStyle
    static func appIcon(size: CGFloat) -> AppIconButtonStyle {
        AppIconButtonStyle(size: size)
    }
}

// MARK: - GlassButtonStyle
// Transparent button with glass background effect

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(configuration.isPressed ? .textSecondary : .textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Spacing.cornerMedium)
                    .fill(configuration.isPressed ? Color.activeBackground : Color.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Spacing.cornerMedium)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
            )
    }
}

// MARK: - GlassButtonStyle Convenience Extension

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}
