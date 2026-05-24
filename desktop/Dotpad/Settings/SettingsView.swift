import SwiftUI

/// The gear popover. Four tabs mirroring Tot: Control, Appearance, Behavior,
/// And More.
struct SettingsView: View {
    @ObservedObject var prefs: Preferences
    @Environment(\.theme) private var theme

    enum Tab: String, CaseIterable, Identifiable {
        case control, appearance, behavior, more
        var id: String { rawValue }
        var label: String {
            switch self {
            case .control: return "Control"
            case .appearance: return "Appearance"
            case .behavior: return "Behavior"
            case .more: return "And More…"
            }
        }
        var icon: String {
            switch self {
            case .control: return "switch.2"
            case .appearance: return "circle.lefthalf.filled"
            case .behavior: return "command"
            case .more: return "ellipsis.bubble"
            }
        }
    }

    @State private var tab: Tab = .control

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            footer
        }
        .frame(width: 460)
        .background(theme.chromeBackground)
    }

    private var header: some View {
        HStack(spacing: 24) {
            ForEach(Tab.allCases) { t in
                Button { tab = t } label: {
                    VStack(spacing: 4) {
                        Image(systemName: t.icon).font(.system(size: 16))
                        Text(t.label).font(.system(size: 11))
                    }
                    .foregroundStyle(tab == t ? theme.controlTint : theme.secondaryText)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    @ViewBuilder private var content: some View {
        switch tab {
        case .control: control
        case .appearance: appearance
        case .behavior: behavior
        case .more: more
        }
    }

    // MARK: Control

    private var control: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Activate with:")
                Picker("", selection: $prefs.activateWith) {
                    ForEach(ActivateWith.allCases) { Text($0.label).tag($0) }
                }
                .labelsHidden()
                .frame(width: 180)
            }
            HStack {
                Text("Show window:")
                ShortcutRecorder(prefs: prefs)
            }
            Divider()
            Toggle("Start Dotpad at login", isOn: $prefs.startAtLogin)
                .onChange(of: prefs.startAtLogin) { LoginItem.set($0) }
            Button("Quit Dotpad") { NSApp.terminate(nil) }
        }
    }

    // MARK: Appearance

    private var appearance: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Theme:")
                Picker("", selection: $prefs.theme) {
                    ForEach(AppTheme.allCases) { Text($0.label).tag($0) }
                }
                .labelsHidden()
                .frame(width: 140)
            }
            Toggle("Add color highlights to text", isOn: $prefs.colorHighlights)
            Toggle("Use vibrant background", isOn: $prefs.vibrantBackground)
            Toggle("Show dot number in title bar", isOn: $prefs.showDotNumberInTitle)
            Toggle("Show dot color on menu bar icon", isOn: $prefs.showDotColorOnMenuBar)
            HStack {
                Text("Smart Bullets:")
                Button("Customize…") {}
            }
        }
    }

    // MARK: Behavior

    private var behavior: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Window").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.secondaryText)
            Toggle("Escape key closes window", isOn: $prefs.escapeClosesWindow)
            Toggle("Display as floating window", isOn: $prefs.floatingWindow)
            Toggle("Window hotkey follows mouse", isOn: $prefs.hotkeyFollowsMouse)
            Divider()
            Text("Text").font(.system(size: 12, weight: .semibold)).foregroundStyle(theme.secondaryText)
            Toggle("Automatically indent lists", isOn: $prefs.autoIndentLists)
            Toggle("Indent plain text", isOn: $prefs.indentPlainText)
                .disabled(!prefs.autoIndentLists)
        }
    }

    // MARK: And More

    private var more: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dotpad").font(.system(size: 18, weight: .bold))
            Text("A menu-bar note editor.").foregroundStyle(theme.secondaryText)
            Link("Project README", destination: URL(fileURLWithPath: "/"))
                .disabled(true)
        }
    }

    private var footer: some View {
        HStack {
            Text("VERSION 0.1.0").font(.system(size: 10)).foregroundStyle(theme.secondaryText)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
