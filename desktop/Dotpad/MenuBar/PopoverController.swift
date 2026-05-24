import AppKit
import SwiftUI

/// Manages the anchored editor popover.
final class PopoverController: NSObject, NSPopoverDelegate {
    private let popover: NSPopover
    private let store: DotStore

    init(store: DotStore) {
        self.store = store
        popover = NSPopover()
        super.init()
        popover.animates = true
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: EditorView(store: store))
        popover.contentSize = NSSize(width: 420, height: 520)
        applyBehavior()
    }

    private func applyBehavior() {
        popover.behavior = Preferences.shared.floatingWindow ? .applicationDefined : .transient
    }

    func toggle(relativeTo view: NSView) {
        if popover.isShown { close() } else { show(relativeTo: view) }
    }

    func show(relativeTo view: NSView) {
        applyBehavior()
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    func close() {
        store.flushSave()
        popover.performClose(nil)
    }
}
