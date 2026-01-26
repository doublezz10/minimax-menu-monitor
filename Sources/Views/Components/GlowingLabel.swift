import SwiftUI

struct GlowingText: View {
    let text: String
    let style: TextStyle

    enum TextStyle {
        case title
        case headline
        case body
        case caption
    }

    @State private var isGlowing = false

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(.white)
            .shadow(color: glowColor, radius: isGlowing ? 15 : 5, x: 0, y: isGlowing ? 8 : 3)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }

    private var font: Font {
        switch style {
        case .title:
            return .largeTitle.weight(.bold)
        case .headline:
            return .headline.weight(.semibold)
        case .body:
            return .body
        case .caption:
            return .caption
        }
    }

    private var glowColor: Color {
        switch style {
        case .title:
            return Color.cyan.opacity(0.8)
        case .headline:
            return Color.purple.opacity(0.7)
        case .body:
            return Color.blue.opacity(0.6)
        case .caption:
            return Color.white.opacity(0.5)
        }
    }
}

struct GradientText: View {
    let text: String
    let colors: [Color]

    var body: some View {
        Text(text)
            .font(.title.weight(.bold))
            .foregroundColor(.clear)
            .overlay(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask(Text(text))
            )
    }
}

struct PulsingIcon: View {
    let icon: String
    let color: Color

    @State private var isPulsing = false

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundColor(color)
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct AnimatedCheckmark: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 48))
            .foregroundColor(.green)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

#Preview {
    VStack(spacing: 24) {
        GlowingText(text: "Glowing Title", style: .title)
        GlowingText(text: "Glowing Headline", style: .headline)

        GradientText(
            text: "Gradient Text",
            colors: [.cyan, .blue, .purple]
        )

        HStack(spacing: 20) {
            PulsingIcon(icon: "chart.bar.fill", color: .cyan)
            PulsingIcon(icon: "chart.pie.fill", color: .purple)
        }

        AnimatedCheckmark()
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
