import SwiftUI

/// Horizontal rail of colored dots with an add button. Tap selects, long-press
/// reveals move/delete.
struct DotRailView: View {
    @ObservedObject var store: DotStore
    @Environment(\.theme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
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
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: 22, height: 22)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: 260)
    }
}

/// A single dot in the rail. Filled when active, ring outline otherwise.
struct DotView: View {
    let colorHex: String
    let isActive: Bool

    var body: some View {
        let color = Color(hex: colorHex)
        ZStack {
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 18, height: 18)
            if isActive {
                Circle()
                    .fill(color)
                    .frame(width: 18, height: 18)
            }
        }
        .frame(width: 24, height: 24)
        .contentShape(Circle())
    }
}
