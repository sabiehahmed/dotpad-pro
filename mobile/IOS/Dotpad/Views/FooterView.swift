import SwiftUI
import UIKit

struct FooterView: View {
    @ObservedObject var store: DotStore
    @Binding var showingBullets: Bool
    var onToggleMode: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: store.activeDot?.colorHex ?? "#888888"))
                .frame(width: 8, height: 8)

            Text(statsLine)
                .font(.system(size: 12))
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            Button { showingBullets = true } label: {
                Image(systemName: "asterisk")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(theme.secondaryText)

            Button(action: onToggleMode) {
                Text(store.activeDot?.mode == .rich ? "a" : "A")
                    .font(.system(size: 16, weight: .semibold,
                                  design: store.activeDot?.mode == .rich ? .default : .monospaced))
            }
            .foregroundStyle(theme.secondaryText)

            Button { dismissKeyboard() } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(theme.secondaryText)
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }

    private var statsLine: String {
        let s = store.stats
        return "\(s.lines) lines · \(s.words) words · \(s.characters) characters"
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
