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

    // MARK: Catalog

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

    // MARK: Continuation engine (pure)

    static let continuingMarkers: [String] =
        ["○", "●", "□", "■", "▷", "▶", "☆", "★", "-", "+", "✓", "❌", "✅", "⭕️", "🔴"]

    static let togglePairs: [String: String] = [
        "○": "●", "●": "○",
        "□": "■ ", "■": "□",
        "☆": "★ ", "★": "☆",
        "❌": "✅", "✅": "❌",
        "⭕️": "🔴", "🔴": "⭕️",
    ]

    static func togglePairs(from pairs: [SmartBulletPair]) -> [String: String] {
        var dict: [String: String] = [:]
        for pair in pairs where !pair.start.isEmpty && !pair.finish.isEmpty {
            dict[pair.start + " "] = pair.finish + " "
            dict[pair.finish + " "] = pair.start + " "
        }
        return dict
    }

    static func allMarkers(from pairs: [SmartBulletPair]) -> [String] {
        var result = continuingMarkers
        for pair in pairs {
            for glyph in [pair.start, pair.finish] where !glyph.isEmpty {
                let m = glyph + " "
                if !result.contains(m) { result.append(m) }
            }
        }
        return result
    }

    struct LineBullet: Equatable {
        let indent: String
        let marker: String
    }

    static func detect(line: String) -> LineBullet? {
        detect(line: line, using: continuingMarkers)
    }

    static func detect(line: String, using markers: [String]) -> LineBullet? {
        let indent = String(line.prefix { $0 == " " || $0 == "\t" })
        let rest = String(line.dropFirst(indent.count))
        for marker in markers.sorted(by: { $0.count > $1.count }) {
            if rest.hasPrefix(marker) {
                return LineBullet(indent: indent, marker: marker)
            }
        }
        return nil
    }

    static func isEmptyBullet(line: String, bullet: LineBullet) -> Bool {
        let prefixLen = bullet.indent.count + bullet.marker.count
        let after = String(line.dropFirst(prefixLen))
        return after.trimmingCharacters(in: .whitespaces).isEmpty
    }

    enum ReturnAction: Equatable {
        case none
        case clearLine(prefixLength: Int)
        case continueList(insert: String)
    }

    static func handleReturn(line: String) -> ReturnAction {
        handleReturn(line: line, markers: continuingMarkers)
    }

    static func handleReturn(line: String, markers: [String]) -> ReturnAction {
        guard let bullet = detect(line: line, using: markers) else { return .none }
        if isEmptyBullet(line: line, bullet: bullet) {
            return .clearLine(prefixLength: bullet.indent.count + bullet.marker.count)
        }
        return .continueList(insert: "\n" + bullet.indent + bullet.marker)
    }
}
