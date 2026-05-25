import SwiftUI

/// The `*` footer popover: pick a bullet/divider to insert at the caret.
struct SmartBulletsPopover: View {
    @ObservedObject var actions: EditorActions
    @Environment(\.theme) private var theme
    var onPick: () -> Void = {}

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            smartSection
            section("DIVIDERS", items: SmartBullets.dividers)
            section("BULLETS", items: SmartBullets.plain)
        }
        .padding(18)
        .frame(width: 320)
        .background(theme.chromeBackground)
    }

    private var smartSection: some View {
        let pairs = Preferences.shared.smartBulletPairs.filter { !$0.start.isEmpty }
        return VStack(alignment: .leading, spacing: 10) {
            Text("SMART BULLETS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
                .tracking(0.6)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(pairs) { pair in
                    Button {
                        actions.insertAtCaret?(pair.start + " ")
                        actions.focus?()
                        onPick()
                    } label: {
                        VStack(spacing: 1) {
                            Text(pair.start)
                                .font(.system(size: 14))
                            if !pair.finish.isEmpty {
                                Text(pair.finish)
                                    .font(.system(size: 12))
                                    .opacity(0.6)
                            }
                        }
                        .foregroundStyle(theme.textColor)
                        .frame(width: 34, height: pair.finish.isEmpty ? 28 : 40)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func section(_ title: String, items: [BulletItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.secondaryText)
                .tracking(0.6)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    Button {
                        actions.insertAtCaret?(item.inserts)
                        actions.focus?()
                        onPick()
                    } label: {
                        Text(item.glyph)
                            .font(.system(size: 16))
                            .foregroundStyle(theme.textColor)
                            .frame(width: 34, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
