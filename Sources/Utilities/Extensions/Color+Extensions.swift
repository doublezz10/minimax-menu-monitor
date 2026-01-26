import SwiftUI

extension Color {
    static let neonCyan = Color(red: 0.0, green: 1.0, blue: 0.8)
    static let neonPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
    static let neonBlue = Color(red: 0.2, green: 0.4, blue: 1.0)
    static let glassWhite = Color.white.opacity(0.2)
    static let glassBorder = Color.white.opacity(0.3)
}

extension View {
    func glow(color: Color = .cyan, radius: CGFloat = 10) -> some View {
        self.shadow(color: color.opacity(0.8), radius: radius, x: 0, y: 0)
    }

    func neonGlow() -> some View {
        self.shadow(color: .neonCyan.opacity(0.8), radius: 15, x: 0, y: 5)
    }
}
