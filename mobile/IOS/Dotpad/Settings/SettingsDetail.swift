import SwiftUI

struct AppearanceSettings: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $prefs.theme) {
                    ForEach(AppTheme.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Section("Background") {
                Toggle("Tint background with dot color", isOn: $prefs.accentBackground)
            }
            Section {
                Toggle("Add color highlights to text", isOn: $prefs.colorHighlights)
            } header: {
                Text("Text")
            } footer: {
                Text("Highlights Markdown headings, bold, and links in plain-text dots.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TextLayoutSettings: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        Form {
            Section("Font Size") {
                Picker("Font Size", selection: $prefs.fontSize) {
                    ForEach(FontSizeOption.allCases) { Text($0.label).tag($0) }
                }
            }
            Section {
                Toggle("Auto-indent wrapped lines", isOn: $prefs.autoIndentLists)
                Toggle("Indent plain text", isOn: $prefs.indentPlainText)
            } header: {
                Text("Lists")
            } footer: {
                Text("Automatically formats text that begins with bullets or smart bullets.")
            }
        }
        .navigationTitle("Text & Layout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BehaviorSettings: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        Form {
            Section("Typing") {
                Toggle("Autocorrection", isOn: $prefs.autocorrect)
                Toggle("Smart dashes", isOn: $prefs.smartDashes)
            }
            Section {
                Toggle("Haptic feedback", isOn: $prefs.hapticFeedback)
            } header: {
                Text("Feedback")
            } footer: {
                Text("Vibrate when toggling a smart bullet.")
            }
        }
        .navigationTitle("Behavior")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdvancedSettings: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    SmartBulletsSettingsView(prefs: prefs)
                } label: {
                    Label("Customize Smart Bullets", systemImage: "list.bullet.circle")
                }
            } header: {
                Text("Smart Bullets")
            } footer: {
                Text("Assign symbols or emoji as smart bullets, with up to eight custom options.")
            }
            Section {
                Button("Reset Smart Bullets", role: .destructive) {
                    prefs.smartBulletPairs = SmartBulletPair.defaults
                }
            }
        }
        .navigationTitle("Advanced Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
