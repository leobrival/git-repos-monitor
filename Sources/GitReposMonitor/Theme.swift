import SwiftUI
import AppKit

// Adaptive Vercel-inspired theme (dark + light mode)
enum Theme {
    // Backgrounds
    static var bg: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1) // #111
                : NSColor(red: 1, green: 1, blue: 1, alpha: 1)             // #fff
        })
    }

    static var bgCard: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)       // #1a1a1a
                : NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)    // #fafafa
        })
    }

    static var bgCardHover: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)    // #222
                : NSColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)    // #f5f5f5
        })
    }

    static var bgElevated: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)    // #262626
                : NSColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)    // #f0f0f0
        })
    }

    // Borders
    static var border: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.08)
                : NSColor(white: 0, alpha: 0.08)
        })
    }

    static var borderSubtle: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.05)
                : NSColor(white: 0, alpha: 0.05)
        })
    }

    // Text
    static var textPrimary: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 1)
                : NSColor(white: 0, alpha: 1)
        })
    }

    static var textSecondary: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.5)
                : NSColor(white: 0, alpha: 0.5)
        })
    }

    static var textTertiary: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.3)
                : NSColor(white: 0, alpha: 0.35)
        })
    }

    static var textMuted: Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(white: 1, alpha: 0.2)
                : NSColor(white: 0, alpha: 0.2)
        })
    }

    // Accents (same in both modes)
    static let success = Color(red: 0.18, green: 0.82, blue: 0.42)         // #2ecb6b
    static let warning = Color(red: 0.96, green: 0.76, blue: 0.15)         // #f5c226
    static let error = Color(red: 0.93, green: 0.26, blue: 0.26)           // #ed4242
    static let info = Color(red: 0.2, green: 0.52, blue: 1.0)              // #3385ff

    // Radius
    static let radiusSm: CGFloat = 4
    static let radiusMd: CGFloat = 6
    static let radiusLg: CGFloat = 8
}
