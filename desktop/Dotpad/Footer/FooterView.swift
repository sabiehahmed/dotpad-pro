import SwiftUI

struct FooterView: View {
    @ObservedObject var store: DotStore
    @Binding var showingBullets: Bool
    var onToggleMode: () -> Void
    var onShare: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: store.activeDot?.colorHex ?? "#888888"))
                .frame(width: 8, height: 8)

            Text(statsLine)
                .font(.system(size: 11))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)

            Spacer()

            Button { showingBullets.toggle() } label: {
                Image(systemName: "asterisk")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.secondaryText)
            .help("Smart Bullets")
            .popover(isPresented: $showingBullets, arrowEdge: .bottom) {
                SmartBulletsPopover(actions: EditorActionsHolder.shared.actions) {
                    showingBullets = false
                }
                .environment(\.theme, theme)
                .environment(\.colorScheme, theme.isDark ? .dark : .light)
            }

            Button(action: onToggleMode) {
                Text(store.activeDot?.mode == .rich ? "a" : "A")
                    .font(.system(size: 15, weight: .semibold, design: store.activeDot?.mode == .rich ? .default : .monospaced))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.secondaryText)
            .help(store.activeDot?.mode == .rich ? "Switch to Plain Text" : "Switch to Rich Text")

            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.secondaryText)
            .help("Share")
        }
        .padding(.horizontal, 14)
        .frame(height: 30)
    }

    private var statsLine: String {
        let s = store.stats
        var base = "\(s.lines) lines · \(s.words) words · \(s.characters) characters"
        if let saved = store.lastSaved {
            base += " · \(Self.relative(saved))"
        }
        return base
    }

    static func relative(_ date: Date) -> String {
        let secs = Int(Date().timeIntervalSince(date))
        switch secs {
        case ..<5: return "Just now"
        case ..<60: return "\(secs)s ago"
        case ..<3600: return "\(secs / 60)m ago"
        default: return "\(secs / 3600)h ago"
        }
    }
}

/// Lets the footer's bullets popover reach the live `EditorActions` instance
/// without threading it through every initializer.
final class EditorActionsHolder {
    static let shared = EditorActionsHolder()
    let actions = EditorActions()
    private init() {}
}
