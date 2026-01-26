import SwiftUI

struct GlassCard: View {
    var cornerRadius: CGFloat = 16
    var blurRadius: CGFloat = 20
    var opacity: Double = 0.2

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(opacity),
                        Color.white.opacity(opacity * 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

struct GlassButton<Content: View>: View {
    let action: () -> Void
    let content: () -> Content

    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }

    var body: some View {
        Button(action: action) {
            content()
                .background(GlassCard())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassCard()
            .frame(width: 200, height: 100)

        GlassButton(action: {}) {
            Text("Glass Button")
                .foregroundColor(.white)
                .padding()
        }
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
