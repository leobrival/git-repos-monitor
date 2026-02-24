import SwiftUI

// Vercel-inspired dark theme
enum Theme {
    // Backgrounds
    static let bg = Color(red: 0.067, green: 0.067, blue: 0.067)           // #111
    static let bgCard = Color(red: 0.1, green: 0.1, blue: 0.1)             // #1a1a1a
    static let bgCardHover = Color(red: 0.13, green: 0.13, blue: 0.13)     // #222
    static let bgElevated = Color(red: 0.15, green: 0.15, blue: 0.15)      // #262626

    // Borders
    static let border = Color.white.opacity(0.08)
    static let borderSubtle = Color.white.opacity(0.05)

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let textTertiary = Color.white.opacity(0.3)
    static let textMuted = Color.white.opacity(0.2)

    // Accents
    static let success = Color(red: 0.18, green: 0.82, blue: 0.42)         // #2ecb6b
    static let warning = Color(red: 0.96, green: 0.76, blue: 0.15)         // #f5c226
    static let error = Color(red: 0.93, green: 0.26, blue: 0.26)           // #ed4242
    static let info = Color(red: 0.2, green: 0.52, blue: 1.0)              // #3385ff

    // Radius
    static let radiusSm: CGFloat = 4
    static let radiusMd: CGFloat = 6
    static let radiusLg: CGFloat = 8
}
