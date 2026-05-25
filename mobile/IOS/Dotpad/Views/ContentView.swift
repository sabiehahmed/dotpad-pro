import SwiftUI
import UIKit

/// Root surface: top dot rail + `···` menu, a swipe-paged editor, and the
/// stats/actions footer.
struct ContentView: View {
    @ObservedObject var store: DotStore
    @ObservedObject var prefs: Preferences

    @Environment(\.colorScheme) private var systemScheme
    @State private var showingSettings = false
    @State private var showingBullets = false
    @State private var scrolledId: UUID?

    private var theme: Theme { Theme.resolve(prefs.theme, system: systemScheme) }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 14)
                    .frame(height: 44)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(store.dots) { dot in
                            DotPage(dot: dot, store: store, prefs: prefs, isDark: theme.isDark)
                                .containerRelativeFrame(.horizontal)
                                .id(dot.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(id: $scrolledId)
                .onAppear { scrolledId = store.activeDotId }
                .onChange(of: scrolledId) { _, new in
                    if let new, new != store.activeDotId { store.select(new) }
                }
                .onChange(of: store.activeDotId) { _, new in
                    if scrolledId != new { withAnimation(.easeInOut(duration: 0.25)) { scrolledId = new } }
                }

                Divider().overlay(theme.separator)
                FooterView(
                    store: store,
                    showingBullets: $showingBullets,
                    onToggleMode: toggleMode
                )
                .environment(\.theme, theme)
            }
        }
        .preferredColorScheme(theme.isDark ? .dark : .light)
        .environment(\.theme, theme)
        .tint(theme.controlTint)
        .sheet(isPresented: $showingSettings) {
            SettingsView(store: store, prefs: prefs)
                .environment(\.theme, theme)
        }
        .sheet(isPresented: $showingBullets) {
            SmartBulletsPicker(actions: EditorActionsHolder.shared.actions, prefs: prefs) {
                showingBullets = false
            }
            .environment(\.theme, theme)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear { applyNavBarTheme() }
    }

    // MARK: Top bar

    private var topBar: some View {
        ZStack {
            DotRailView(store: store).environment(\.theme, theme)

            HStack {
                Spacer()
                Menu {
                    Button { showingSettings = true } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    Button { store.addDot() } label: {
                        Label("New Dot", systemImage: "plus.circle")
                    }
                    Button(role: .destructive) {
                        if let id = store.activeDotId { store.removeDot(id) }
                    } label: {
                        Label("Delete Dot", systemImage: "trash")
                    }
                    .disabled(store.dots.count <= 1)
                    Divider()
                    Button { toggleMode() } label: {
                        Label(store.activeDot?.mode == .rich ? "Plain Text" : "Rich Text",
                              systemImage: "textformat")
                    }
                    if let text = currentShareText {
                        ShareLink(item: text) { Label("Share", systemImage: "square.and.arrow.up") }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: 34, height: 28)
                        .background(theme.chromeBackground, in: Capsule())
                }
            }
        }
    }

    private var currentShareText: String? {
        let s = store.activeContent.string
        return s.isEmpty ? nil : s
    }

    private func toggleMode() {
        guard let dot = store.activeDot else { return }
        store.setMode(dot.mode == .rich ? .plain : .rich, for: dot.id)
    }

    // MARK: Background

    @ViewBuilder private var background: some View {
        if prefs.accentBackground {
            accentColor
        } else {
            theme.windowBackground
        }
    }

    /// Active dot color blended heavily toward black (dark) or cream (light).
    private var accentColor: Color {
        let hex = store.activeDot?.colorHex ?? "#888888"
        let base = UIColor(Color(hex: hex))
        let target: UIColor = theme.isDark ? .black : UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1)
        let frac: CGFloat = theme.isDark ? 0.86 : 0.84
        return Color(base.blended(toward: target, fraction: frac))
    }

    private func applyNavBarTheme() {}
}

private extension UIColor {
    func blended(toward other: UIColor, fraction f: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(
            red: r1 + (r2 - r1) * f,
            green: g1 + (g2 - g1) * f,
            blue: b1 + (b2 - b1) * f,
            alpha: 1
        )
    }
}

/// One page in the swipe carousel: the live editor for the active dot, a
/// static preview otherwise.
private struct DotPage: View {
    let dot: Dot
    @ObservedObject var store: DotStore
    @ObservedObject var prefs: Preferences
    let isDark: Bool

    @Environment(\.theme) private var theme

    var body: some View {
        Group {
            if dot.id == store.activeDotId {
                DotTextView(
                    store: store,
                    actions: EditorActionsHolder.shared.actions,
                    prefs: prefs,
                    isDark: isDark
                )
            } else {
                ScrollView {
                    Text(store.previewText(for: dot))
                        .font(dot.mode == .plain
                              ? .system(size: CGFloat(prefs.fontSize.rawValue) - 1, design: .monospaced)
                              : .system(size: CGFloat(prefs.fontSize.rawValue)))
                        .foregroundStyle(theme.textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.top, 16)
                }
            }
        }
    }
}
