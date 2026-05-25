import SwiftUI

struct SmartBulletPair: Codable, Identifiable, Equatable {
    var id: UUID
    var start: String
    var finish: String

    init(id: UUID = UUID(), start: String, finish: String) {
        self.id = id
        self.start = start
        self.finish = finish
    }

    static let presets: [(label: String, start: String, finish: String)] = [
        ("Circle",       "○", "●"),
        ("Square",       "□", "■"),
        ("Triangle",     "▷", "▶"),
        ("Star",         "☆", "★"),
        ("Minus/Check",  "-", "✓"),
        ("Cross/Check",  "❌", "✅"),
        ("Red Dot",      "⭕️", "🔴"),
    ]

    static let defaults: [SmartBulletPair] = presets.map { .init(start: $0.start, finish: $0.finish) }
}

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

enum FontSizeOption: Int, CaseIterable, Identifiable {
    case small = 15, medium = 17, large = 19, xlarge = 22
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .xlarge: return "Extra Large"
        }
    }
}

/// UserDefaults-backed settings, surfaced to the settings screens.
final class Preferences: ObservableObject {
    static let shared = Preferences()

    @AppStorage("theme") var theme: AppTheme = .dark
    @AppStorage("colorHighlights") var colorHighlights: Bool = true
    @AppStorage("accentBackground") var accentBackground: Bool = true
    @AppStorage("fontSize") var fontSize: FontSizeOption = .medium

    @AppStorage("autoIndentLists") var autoIndentLists: Bool = true
    @AppStorage("indentPlainText") var indentPlainText: Bool = false
    @AppStorage("autocorrect") var autocorrect: Bool = true
    @AppStorage("smartDashes") var smartDashes: Bool = false
    @AppStorage("hapticFeedback") var hapticFeedback: Bool = true

    @AppStorage("smartBulletPairsJSON") private var smartBulletPairsJSON: String = ""

    var smartBulletPairs: [SmartBulletPair] {
        get {
            guard !smartBulletPairsJSON.isEmpty,
                  let data = smartBulletPairsJSON.data(using: .utf8),
                  let pairs = try? JSONDecoder().decode([SmartBulletPair].self, from: data)
            else { return SmartBulletPair.defaults }
            return pairs
        }
        set {
            objectWillChange.send()
            guard let data = try? JSONEncoder().encode(newValue),
                  let str = String(data: data, encoding: .utf8) else { return }
            smartBulletPairsJSON = str
        }
    }

    private init() {}
}
