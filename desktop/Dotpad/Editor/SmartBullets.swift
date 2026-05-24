import Foundation

/// One selectable item in the smart-bullets picker.
struct BulletItem: Identifiable, Equatable {
    enum Kind { case smart, divider, plain }
    let id: String
    let glyph: String       // shown in the picker grid
    let inserts: String     // text inserted at the caret
    let kind: Kind
}

/// Catalog of pickable markers (mirrors the three sections in the Tot picker)
/// plus the pure list-continuation logic used by the editor coordinator.
enum SmartBullets {

    // MARK: Catalog (screenshot-faithful)

    static let smart: [BulletItem] = [
        .init(id: "circle",   glyph: "●", inserts: "○ ", kind: .smart),
        .init(id: "square",   glyph: "■", inserts: "□ ", kind: .smart),
        .init(id: "triangle", glyph: "▶", inserts: "▷ ", kind: .smart),
        .init(id: "star",     glyph: "★", inserts: "☆ ", kind: .smart),
        .init(id: "plus",     glyph: "+", inserts: "+ ", kind: .smart),
        .init(id: "check",    glyph: "✓", inserts: "- ", kind: .smart),
        .init(id: "cross",    glyph: "✅", inserts: "❌ ", kind: .smart),
        .init(id: "reddot",   glyph: "🔴", inserts: "⭕️ ", kind: .smart),
    ]

    static let dividers: [BulletItem] = [
        .init(id: "rule1", glyph: "———", inserts: "———\n", kind: .divider),
        .init(id: "rule2", glyph: "–·–", inserts: "–·–·–\n", kind: .divider),
        .init(id: "rule3", glyph: "═══", inserts: "═══\n", kind: .divider),
        .init(id: "rule4", glyph: "·-·", inserts: "·-·-·\n", kind: .divider),
        .init(id: "rule5", glyph: "▬▬", inserts: "▬▬▬\n", kind: .divider),
        .init(id: "rule6", glyph: "⋯", inserts: "⋯⋯⋯\n", kind: .divider),
    ]

    static let plain: [BulletItem] = [
        .init(id: "middot",   glyph: "·",  inserts: "· ",  kind: .plain),
        .init(id: "bullet",   glyph: "•",  inserts: "• ",  kind: .plain),
        .init(id: "asterism", glyph: "✳︎", inserts: "✳︎ ", kind: .plain),
        .init(id: "sparkle",  glyph: "✸",  inserts: "✸ ",  kind: .plain),
        .init(id: "star4",    glyph: "✦",  inserts: "✦ ",  kind: .plain),
        .init(id: "diamond",  glyph: "◆",  inserts: "◆ ",  kind: .plain),
        .init(id: "diamondO", glyph: "◇",  inserts: "◇ ",  kind: .plain),
        .init(id: "diamondX", glyph: "◈",  inserts: "◈ ",  kind: .plain),
    ]

    // MARK: Continuation engine (pure, unit-tested)

    /// Markers that auto-continue on Return. Includes both toggle states so a
    /// continued/checked line is still recognized.
    static let continuingMarkers: [String] =
        ["○ ", "● ", "□ ", "■ ", "▷ ", "▶ ", "☆ ", "★ ", "- ", "+ ", "✓ ", "❌ ", "✅ ", "⭕️ ", "🔴 "]

    /// Maps a marker to its toggled counterpart (for checkbox clicks).
    static let togglePairs: [String: String] = [
        "○ ": "● ", "● ": "○ ",
        "□ ": "■ ", "■ ": "□ ",
        "☆ ": "★ ", "★ ": "☆ ",
        "❌ ": "✅ ", "✅ ": "❌ ",
        "⭕️ ": "🔴 ", "🔴 ": "⭕️ ",
    ]

    struct LineBullet: Equatable {
        let indent: String
        let marker: String
    }

    /// Detects a leading bullet marker on a line (after optional indent).
    static func detect(line: String) -> LineBullet? {
        let indent = String(line.prefix { $0 == " " || $0 == "\t" })
        let rest = String(line.dropFirst(indent.count))
        for marker in continuingMarkers.sorted(by: { $0.count > $1.count }) {
            if rest.hasPrefix(marker) {
                return LineBullet(indent: indent, marker: marker)
            }
        }
        return nil
    }

    /// True when the line holds only indent + marker (no content) — i.e. an
    /// empty bullet, which terminates the list on Return.
    static func isEmptyBullet(line: String, bullet: LineBullet) -> Bool {
        let prefixLen = bullet.indent.count + bullet.marker.count
        let after = String(line.dropFirst(prefixLen))
        return after.trimmingCharacters(in: .whitespaces).isEmpty
    }

    enum ReturnAction: Equatable {
        case none                       // not a bullet line — default newline
        case clearLine(prefixLength: Int) // empty bullet — strip the marker
        case continueList(insert: String) // non-empty — newline + indent + marker
    }

    /// Decides what Return should do given the current line text.
    static func handleReturn(line: String) -> ReturnAction {
        guard let bullet = detect(line: line) else { return .none }
        if isEmptyBullet(line: line, bullet: bullet) {
            return .clearLine(prefixLength: bullet.indent.count + bullet.marker.count)
        }
        return .continueList(insert: "\n" + bullet.indent + bullet.marker)
    }
}
