import SwiftUI

/// Settings root: gradient header + Configuration and Help & About sections.
struct SettingsView: View {
    @ObservedObject var store: DotStore
    @ObservedObject var prefs: Preferences
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            List {
                Section { header.listRowInsets(EdgeInsets()).listRowBackground(Color.clear) }

                Section("Configuration") {
                    NavigationLink { AppearanceSettings(prefs: prefs) } label: {
                        rowLabel("Appearance", "paintpalette")
                    }
                    NavigationLink { TextLayoutSettings(prefs: prefs) } label: {
                        rowLabel("Text & Layout", "textformat.size")
                    }
                    NavigationLink { BehaviorSettings(prefs: prefs) } label: {
                        rowLabel("Behavior", "slider.horizontal.3")
                    }
                    NavigationLink { AdvancedSettings(prefs: prefs) } label: {
                        rowLabel("Advanced Settings", "gearshape.2")
                    }
                }

                Section {
                    Text("For more information about these settings, check out the User Manual.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)

                Section("Help & About") {
                    aboutRow("Smart Bullets", "list.bullet")
                    aboutRow("What's New in Dotpad", "sparkles")
                    aboutRow("Get Support", "questionmark.circle")
                    NavigationLink { AboutView() } label: { rowLabel("About", "info.circle") }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            Text("Dotpad")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            HStack(spacing: 8) {
                ForEach(DotStore.palette + ["#27AE60"], id: \.self) { hex in
                    Circle().fill(Color(hex: hex)).frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(.black.opacity(0.25), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(
            LinearGradient(
                colors: [Color(hex: "#7B5BD6"), Color(hex: "#4A2D8F")],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func rowLabel(_ title: String, _ icon: String) -> some View {
        Label(title, systemImage: icon)
    }

    private func aboutRow(_ title: String, _ icon: String) -> some View {
        Button { } label: {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .foregroundStyle(theme.textColor)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 6) {
                    Text("Dotpad").font(.title.bold())
                    Text("Version 1.0").foregroundStyle(.secondary)
                    Text("A tiny, fast scratchpad for thoughts and lists.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
