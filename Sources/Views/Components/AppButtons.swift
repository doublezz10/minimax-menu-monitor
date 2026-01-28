import SwiftUI

// MARK: - Button Styles
// Consistent button styles for uniform UI across the app

// MARK: - Standard Spacing Constants
// Using 8pt grid system (macOS standard)

private enum ButtonSpacing {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 16
    static let cornerRadius: CGFloat = 6
}

// MARK: - HoverableButtonStyle
// A helper view that tracks hover state for button styles

struct HoverableButtonStyle<Content: View, Background: View>: View {
    let isEnabled: Bool
    @ViewBuilder let content: (Bool, Bool) -> Content
    @ViewBuilder let background: (Bool, Bool) -> Background
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        content(isHovered, isPressed)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(background(isHovered, isPressed))
            .cornerRadius(ButtonSpacing.cornerRadius)
            .opacity(isEnabled ? 1.0 : 0.5)
            .onHover { hovering in
                isHovered = hovering
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isHovered)
            .animation(.spring(response: 0.15, dampingFraction: 0.4), value: isPressed)
    }
}

// MARK: - AppButtonStyle
// Primary button style with variant support and hover states

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
        HoverableButtonStyle(isEnabled: isEnabled) { isHovered, isPressed in
            configuration.label
                .font(.subheadline.weight(.medium))
                .foregroundColor(foregroundColor(for: isPressed, isHovered: isHovered))
                .frame(maxWidth: .infinity)
        } background: { isHovered, isPressed in
            backgroundView(isPressed: isPressed, isHovered: isHovered)
        }
    }
    
    private func foregroundColor(for isPressed: Bool, isHovered: Bool) -> Color {
        switch variant {
        case .primary, .danger:
            return .white
        case .secondary, .ghost:
            return isPressed ? .textSecondary : .textPrimary
        }
    }
    
    private func backgroundView(isPressed: Bool, isHovered: Bool) -> some View {
        Group {
            switch variant {
            case .primary:
                LinearGradient(
                    colors: isPressed ? [Color.neonPurple.opacity(0.7), Color.neonBlue.opacity(0.7)] : 
                                    isHovered ? [Color.neonPurple.opacity(0.9), Color.neonBlue.opacity(0.9)] : 
                                    [Color.neonPurple, Color.neonBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )

            case .secondary:
                RoundedRectangle(cornerRadius: ButtonSpacing.cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 1)
                    .background(isPressed ? Color.activeBackground : (isHovered ? Color.hoverBackground : Color.clear))

            case .ghost:
                Color.clear

            case .danger:
                LinearGradient(
                    colors: [Color.red, Color.orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
}

// MARK: - ButtonStyle Convenience Extension

extension ButtonStyle where Self == AppButtonStyle {
    static func app(variant: AppButtonStyle.Variant = .primary, isEnabled: Bool = true) -> AppButtonStyle {
        AppButtonStyle(variant: variant, isEnabled: isEnabled)
    }
}

// MARK: - Header Button Style
// Compact button style for header/toolbar use with hover states

struct HeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HoverableButtonStyle(isEnabled: true) { isHovered, isPressed in
            HStack(spacing: ButtonSpacing.small) {
                configuration.label
                    .font(.caption)
                    .foregroundColor(isPressed ? .textSecondary : .textPrimary)
            }
        } background: { isHovered, isPressed in
            Capsule()
                .fill(isPressed ? Color.activeBackground : (isHovered ? Color.hoverBackground : Color.cardBackground))
        }
    }
}

// MARK: - HeaderButtonStyle Convenience Extension

extension ButtonStyle where Self == HeaderButtonStyle {
    static var header: HeaderButtonStyle { HeaderButtonStyle() }
}

// MARK: - Icon Button Style with Hover
// Icon-only button with proper hover/press states

struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    let showBackground: Bool
    
    init(size: CGFloat = 24, showBackground: Bool = true) {
        self.size = size
        self.showBackground = showBackground
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HoverableButtonStyle(isEnabled: true) { isHovered, isPressed in
            configuration.label
                .frame(width: size, height: size)
                .foregroundColor(isPressed ? .textSecondary : (isHovered ? .textPrimary : .textSecondary))
        } background: { isHovered, isPressed in
            Group {
                if showBackground {
                    Circle()
                        .fill(isPressed ? Color.activeBackground : (isHovered ? Color.hoverBackground : Color.glassBackground))
                } else {
                    Color.clear
                }
            }
        }
    }
}

// MARK: - IconButtonStyle Convenience Extension

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
    
    static func icon(size: CGFloat) -> IconButtonStyle {
        IconButtonStyle(size: size)
    }
}

// MARK: - GlassButtonStyle
// Transparent button with glass background and hover effects

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HoverableButtonStyle(isEnabled: true) { isHovered, isPressed in
            configuration.label
                .font(.subheadline.weight(.medium))
                .foregroundColor(isPressed ? .textSecondary : .textPrimary)
                .frame(maxWidth: .infinity)
        } background: { isHovered, isPressed in
            RoundedRectangle(cornerRadius: ButtonSpacing.cornerRadius)
                .fill(isPressed ? Color.activeBackground : Color.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: ButtonSpacing.cornerRadius)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - GlassButtonStyle Convenience Extension

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}
