import SwiftUI

extension Font {
    static func neon(size: CGFloat = 24) -> Font {
        Font.system(size: size, weight: .bold, design: .rounded)
    }
}
