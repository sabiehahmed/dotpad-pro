import SwiftUI

struct SmartBulletsSettingsView: View {
    @ObservedObject var prefs: Preferences
    @Environment(\.theme) private var theme
    var onDismiss: () -> Void

    @State private var pairs: [SmartBulletPair] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            columnHeader
            Divider()
            pairsList
            Divider()
            actionRow
        }
        .onAppear { pairs = prefs.smartBulletPairs }
    }

    private var columnHeader: some View {
        HStack(spacing: 0) {
            Text("Start")
                .frame(width: 76, alignment: .center)
            Text("Finish")
                .frame(width: 76, alignment: .center)
            Spacer()
            Text("Preset")
                .frame(width: 120, alignment: .center)
            Spacer().frame(width: 28)
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(theme.secondaryText)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }

    private var pairsList: some View {
        VStack(spacing: 6) {
            ForEach($pairs) { $pair in
                pairRow(pair: $pair)
            }
            Button {
                pairs.append(SmartBulletPair(start: "", finish: ""))
            } label: {
                Label("Add Pair", systemImage: "plus")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.controlTint)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }

    private func pairRow(pair: Binding<SmartBulletPair>) -> some View {
        HStack(spacing: 8) {
            TextField("○", text: pair.start)
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)

            TextField("●", text: pair.finish)
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)

            Spacer()

            Menu {
                ForEach(SmartBulletPair.presets, id: \.label) { preset in
                    Button {
                        pair.wrappedValue.start = preset.start
                        pair.wrappedValue.finish = preset.finish
                    } label: {
                        Text("\(preset.start)  →  \(preset.finish)  \(preset.label)")
                    }
                }
            } label: {
                HStack(spacing: 3) {
                    Text("Preset")
                        .font(.system(size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundStyle(theme.secondaryText)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 80)

            Button {
                pairs.removeAll { $0.id == pair.wrappedValue.id }
            } label: {
                Image(systemName: "minus.circle")
                    .foregroundStyle(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .frame(width: 20)
        }
        .padding(.horizontal, 4)
    }

    private var actionRow: some View {
        HStack {
            Text("One character or emoji per field.")
                .font(.system(size: 11))
                .foregroundStyle(theme.secondaryText)
            Spacer()
            Button("Cancel") { onDismiss() }
                .keyboardShortcut(.escape, modifiers: [])
            Button("Update") {
                prefs.smartBulletPairs = pairs.filter { !$0.start.isEmpty }
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}
