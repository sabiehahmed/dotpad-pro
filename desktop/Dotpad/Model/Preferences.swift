import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark, auto
    var id: String { rawValue }
    var label: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Auto"
        }
    }
}

enum ActivateWith: String, CaseIterable, Identifiable {
    case menuBarIcon, bothIcons
    var id: String { rawValue }
    var label: String {
        switch self {
        case .menuBarIcon: return "Menu Bar Icon"
        case .bothIcons: return "Both Icons"
        }
    }
}

/// UserDefaults-backed settings, surfaced to the 4 settings tabs.
final class Preferences: ObservableObject {
    static let shared = Preferences()

    @AppStorage("theme") var theme: AppTheme = .dark
    @AppStorage("colorHighlights") var colorHighlights: Bool = true
    @AppStorage("vibrantBackground") var vibrantBackground: Bool = true
    @AppStorage("showDotNumberInTitle") var showDotNumberInTitle: Bool = false
    @AppStorage("showDotColorOnMenuBar") var showDotColorOnMenuBar: Bool = true

    @AppStorage("activateWith") var activateWith: ActivateWith = .menuBarIcon
    @AppStorage("startAtLogin") var startAtLogin: Bool = false

    /// Carbon key code + modifier mask for the global show-window hot key.
    @AppStorage("hotKeyCode") var hotKeyCode: Int = 0
    @AppStorage("hotKeyModifiers") var hotKeyModifiers: Int = 0

    @AppStorage("escapeClosesWindow") var escapeClosesWindow: Bool = true
    @AppStorage("floatingWindow") var floatingWindow: Bool = false
    @AppStorage("hotkeyFollowsMouse") var hotkeyFollowsMouse: Bool = false
    @AppStorage("autoIndentLists") var autoIndentLists: Bool = true
    @AppStorage("indentPlainText") var indentPlainText: Bool = false

    private init() {}
}
