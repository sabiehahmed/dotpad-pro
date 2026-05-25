import SwiftUI

/// Editor for the up-to-eight custom smart-bullet pairs (start glyph + toggled
/// finish glyph). Mirrors Tot's "Custom Smart Bullets".
struct SmartBulletsSettingsView: View {
    @ObservedObject var prefs: Preferences
    @State private var pairs: [SmartBulletPair] = []

    private let maxPairs = 8

    var body: some View {
        Form {
            Section {
                ForEach($pairs) { $pair in
                    HStack(spacing: 12) {
                        glyphField("Start", text: $pair.start)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        glyphField("Done", text: $pair.finish)
                        Spacer()
                        previewDots(pair)
                    }
                }
                .onDelete { pairs.remove(atOffsets: $0); save() }
                .onMove { pairs.move(fromOffsets: $0, toOffset: $1); save() }
            } header: {
                Text("Smart Bullet Pairs")
            } footer: {
                Text("The start symbol is inserted; tap it in a note to toggle to the done symbol. Leave Done blank for a one-way bullet.")
            }

            if pairs.count < maxPairs {
                Section {
                    Button {
                        pairs.append(SmartBulletPair(start: "•", finish: ""))
                        save()
                    } label: {
                        Label("Add Smart Bullet", systemImage: "plus.circle")
                    }
                }
            }

            Section {
                Button("Reset to Defaults", role: .destructive) {
                    pairs = SmartBulletPair.defaults
                    save()
                }
            }
        }
        .navigationTitle("Smart Bullets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
        .onAppear { pairs = prefs.smartBulletPairs }
        .onChange(of: pairs) { _, _ in save() }
    }

    private func glyphField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .multilineTextAlignment(.center)
            .font(.system(size: 18))
            .frame(width: 52, height: 36)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }

    private func previewDots(_ pair: SmartBulletPair) -> some View {
        HStack(spacing: 4) {
            Text(pair.start.isEmpty ? "·" : pair.start)
            if !pair.finish.isEmpty {
                Text(pair.finish).opacity(0.5)
            }
        }
        .font(.system(size: 16))
        .foregroundStyle(.secondary)
    }

    private func save() {
        prefs.smartBulletPairs = pairs
    }
}
