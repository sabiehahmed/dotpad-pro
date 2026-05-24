import SwiftUI
import AppKit

extension Notification.Name {
    static let closePopover = Notification.Name("DotpadClosePopover")
}

/// The full editor surface inside the popover: top bar (close · dot rail ·
/// settings), the text editor, and the stats/actions footer.
struct EditorView: View {
    @ObservedObject var store: DotStore
    @ObservedObject private var prefs = Preferences.shared
    @StateObject private var actions = EditorActionsHolderModel()

    @State private var showingSettings = false
    @State private var showingBullets = false
    @Environment(\.colorScheme) private var systemScheme

    private var theme: Theme { Theme.resolve(prefs.theme, system: systemScheme) }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider().overlay(theme.separator)
            DotTextView(store: store, actions: EditorActionsHolder.shared.actions, isDark: theme.isDark)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider().overlay(theme.separator)
            FooterView(
                store: store,
                showingBullets: $showingBullets,
                onToggleMode: toggleMode,
                onShare: share
            )
            .environment(\.theme, theme)
        }
        .frame(width: 420, height: 520)
        .background(background)
        .environment(\.theme, theme)
        .environment(\.colorScheme, theme.isDark ? .dark : .light)
        .onAppear { EditorActionsHolder.shared.actions.focus?() }
    }

    @ViewBuilder private var background: some View {
        if prefs.vibrantBackground {
            ZStack {
                VisualEffectView(material: theme.isDark ? .hudWindow : .headerView)
                theme.windowBackground.opacity(theme.isDark ? 0.55 : 0.93)
            }
            .ignoresSafeArea()
        } else {
            // Vibrant off: tint the background with a dark/light shade of the
            // active dot's color (matches Tot).
            accentBackground
        }
    }

    /// Active dot color blended heavily toward black (dark) or the cream
    /// (light) for the solid, non-vibrant background.
    private var accentBackground: Color {
        let base = NSColor(Color(hex: store.activeDot?.colorHex ?? "#888888"))
            .usingColorSpace(.sRGB) ?? .gray
        if theme.isDark {
            return Color(base.blended(withFraction: 0.88, of: .black) ?? base)
        } else {
            return Color(base.blended(withFraction: 0.86, of: .white) ?? base)
        }
    }

    private var topBar: some View {
        ZStack {
            // Centered dot rail (matches Tot).
            DotRailView(store: store).environment(\.theme, theme)

            HStack {
                Button { NotificationCenter.default.post(name: .closePopover, object: nil) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(theme.secondaryText)
                }
                .buttonStyle(.plain)

                Spacer()

                Button { showingSettings.toggle() } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.secondaryText)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showingSettings, arrowEdge: .bottom) {
                    SettingsView(prefs: prefs)
                        .environment(\.theme, theme)
                        .environment(\.colorScheme, theme.isDark ? .dark : .light)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
    }

    private func toggleMode() {
        guard let dot = store.activeDot else { return }
        store.setMode(dot.mode == .rich ? .plain : .rich, for: dot.id)
    }

    private func share() {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(store.activeContent.string, forType: .string)
    }
}

/// Keeps the SwiftUI lifecycle from deallocating the shared actions object.
final class EditorActionsHolderModel: ObservableObject {
    let holder = EditorActionsHolder.shared
}
