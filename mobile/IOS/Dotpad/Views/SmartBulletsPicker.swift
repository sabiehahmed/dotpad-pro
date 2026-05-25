import SwiftUI

/// The `*` sheet: pick a bullet/divider to insert at the caret.
struct SmartBulletsPicker: View {
    @ObservedObject var actions: EditorActions
    @ObservedObject var prefs: Preferences
    @Environment(\.theme) private var theme
    var onPick: () -> Void = {}

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                smartSection
                section("DIVIDERS", items: SmartBullets.dividers)
                section("BULLETS", items: SmartBullets.plain)
            }
            .padding(20)
        }
        .background(theme.windowBackground.ignoresSafeArea())
    }

    private var smartSection: some View {
        let pairs = prefs.smartBulletPairs.filter { !$0.start.isEmpty }
        return VStack(alignment: .leading, spacing: 12) {
            header("SMART BULLETS")
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(pairs) { pair in
                    Button {
                        insert(pair.start + " ")
                    } label: {
                        VStack(spacing: 1) {
                            Text(pair.start).font(.system(size: 18))
                            if !pair.finish.isEmpty {
                                Text(pair.finish).font(.system(size: 14)).opacity(0.6)
                            }
                        }
                        .foregroundStyle(theme.textColor)
                        .frame(width: 40, height: pair.finish.isEmpty ? 34 : 48)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    private func section(_ title: String, items: [BulletItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            header(title)
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(items) { item in
                    Button {
                        insert(item.inserts)
                    } label: {
                        Text(item.glyph)
                            .font(.system(size: 18))
                            .foregroundStyle(theme.textColor)
                            .frame(width: 40, height: 34)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }

    private func header(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(theme.secondaryText)
            .tracking(0.6)
    }

    private func insert(_ text: String) {
        actions.insertAtCaret?(text)
        actions.focus?()
        onPick()
    }
}
