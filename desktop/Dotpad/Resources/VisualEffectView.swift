import SwiftUI
import AppKit

/// Vibrant NSVisualEffectView backing for the popover (Tot's "vibrant
/// background"). Disabled falls back to a solid color via the caller.
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}
