import SwiftUI

struct LiquidProgressView: View {
    let progress: Double
    let remaining: String
    let total: String

    @State private var time: TimeInterval = 0
    @State private var animatedProgress: Double = 0
    @State private var timer: Timer?

    private let baseAmplitude: CGFloat = 12
    private let animationInterval: TimeInterval = 0.1

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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                startWaveAnimation()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
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
        let baseY = progressHeight

        path.move(to: CGPoint(x: 0, y: height))

        for x in stride(from: 0, through: width, by: 1) {
            let normalizedX = x / width
            
            // Multiple overlapping sine waves for organic lava lamp effect
            // Slow, breathing motion
            let wave1 = sin(normalizedX * .pi * 2 + time * 0.5) * baseAmplitude * 0.5
            let wave2 = sin(normalizedX * .pi * 3 + time * 0.3) * baseAmplitude * 0.3
            let wave3 = sin(normalizedX * .pi * 1.5 + time * 0.7) * baseAmplitude * 0.2
            
            // Slow undulation
            let undulation = sin(time * 0.2) * baseAmplitude * 0.3
            
            let y = baseY + wave1 + wave2 + wave3 + undulation

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
        // Slow, breathing animation like a lava lamp
        timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            time += animationInterval
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
