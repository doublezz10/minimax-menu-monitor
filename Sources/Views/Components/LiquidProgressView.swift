import SwiftUI

struct LiquidProgressView: View {
    let progress: Double
    let remaining: String
    let total: String

    @State private var waveOffset: CGFloat = 0
    @State private var animatedProgress: Double = 0

    private let waveSpeed: CGFloat = 4
    private let waveAmplitude: CGFloat = 25

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient

                waveShape(progress: animatedProgress, in: geometry)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.8),
                                Color.blue.opacity(0.6),
                                Color.purple.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(waveShape(progress: animatedProgress, in: geometry))

                contentOverlay(in: geometry)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = progress
            }
            // Start wave animation after progress fills in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                startWaveAnimation()
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func waveShape(progress: Double, in geometry: GeometryProxy) -> Path {
        var path = Path()

        let width = geometry.size.width
        let height = geometry.size.height
        let progressHeight = height * CGFloat(1 - progress)
        let midY = progressHeight

        path.move(to: CGPoint(x: 0, y: height))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let angle = (relativeX * .pi * 4) + waveOffset
            let y = midY + sin(angle) * waveAmplitude

            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }

    private func contentOverlay(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            Text("\(Int(progress * 100))%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            Text("\(remaining) / \(total)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .position(
            x: geometry.size.width / 2,
            y: geometry.size.height / 2
        )
    }

    private func startWaveAnimation() {
        // Dynamic wave motion - clearly visible
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            waveOffset = .pi * 4
        }
    }
}

struct AnimatedCircleProgress: View {
    let progress: Double
    let lineWidth: CGFloat

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            animatedProgress = newValue
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LiquidProgressView(
            progress: 0.65,
            remaining: "650K",
            total: "1M"
        )
        .frame(height: 200)

        AnimatedCircleProgress(progress: 0.65, lineWidth: 8)
            .frame(width: 100, height: 100)
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
