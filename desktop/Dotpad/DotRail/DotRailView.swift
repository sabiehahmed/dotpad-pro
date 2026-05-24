import SwiftUI

/// Horizontal rail of dots with an add button. Unlimited dots (Tot's extension).
struct DotRailView: View {
    @ObservedObject var store: DotStore
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(store.dots.enumerated()), id: \.element.id) { idx, dot in
                    DotView(colorHex: dot.colorHex, isActive: dot.id == store.activeDotId)
                        .onTapGesture { store.select(dot.id) }
                        .contextMenu {
                            Button("Move Left") { store.move(from: idx, to: idx - 1) }
                                .disabled(idx == 0)
                            Button("Move Right") { store.move(from: idx, to: idx + 2) }
                                .disabled(idx == store.dots.count - 1)
                            Divider()
                            Button("Delete Dot", role: .destructive) { store.removeDot(dot.id) }
                                .disabled(store.dots.count <= 1)
                        }
                }

                Button(action: { store.addDot() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Add dot")
            }
            .padding(.horizontal, 4)
        }
        // Leave room for the close button (left) and gear (right) overlays.
        .frame(maxWidth: 300)
    }
}
