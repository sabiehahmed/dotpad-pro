import SwiftUI

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
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
                .frame(width: 16, height: 16)
            if isActive {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(width: 20, height: 20)
        .contentShape(Circle())
    }
}
