import SwiftUI

struct Theme {
    let isDark: Bool
    let windowBackground: Color
    let chromeBackground: Color
    let textColor: Color
    let secondaryText: Color
    let separator: Color
    let controlTint: Color

    static let light = Theme(
        isDark: false,
        windowBackground: Color(red: 0.984, green: 0.969, blue: 0.933),   // cream
        chromeBackground: Color(red: 0.972, green: 0.953, blue: 0.910),
        textColor: Color(red: 0.12, green: 0.12, blue: 0.12),
        secondaryText: Color(red: 0.55, green: 0.52, blue: 0.45),
        separator: Color.black.opacity(0.08),
        controlTint: Color(red: 0.55, green: 0.50, blue: 0.30)
    )

    static let dark = Theme(
        isDark: true,
        windowBackground: Color(red: 0.13, green: 0.13, blue: 0.13),
        chromeBackground: Color(red: 0.16, green: 0.16, blue: 0.17),
        textColor: Color.white,
        secondaryText: Color(white: 0.55),
        separator: Color.white.opacity(0.10),
        controlTint: Color(white: 0.75)
    )

    static func resolve(_ appTheme: AppTheme, system: ColorScheme) -> Theme {
        switch appTheme {
        case .light: return .light
        case .dark: return .dark
        case .auto: return system == .dark ? .dark : .light
        }
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .dark
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
