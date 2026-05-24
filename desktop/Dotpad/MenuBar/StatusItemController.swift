import AppKit

/// Owns the menu-bar `NSStatusItem` and toggles the editor popover.
final class StatusItemController {
    private let statusItem: NSStatusItem
    private let popoverController: PopoverController

    init(store: DotStore) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popoverController = PopoverController(store: store)
        configureButton()
        observeDotColor(store)
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        let image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Dotpad")
        image?.isTemplate = true
        button.image = image
        button.action = #selector(togglePopover(_:))
        button.target = self
    }

    /// Tints the menu-bar glyph to the active dot's color when enabled.
    private func observeDotColor(_ store: DotStore) {
        // Lightweight: refresh on a short timer-free path via notification.
        NotificationCenter.default.addObserver(
            forName: .closePopover, object: nil, queue: .main
        ) { [weak self] _ in self?.popoverController.close() }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        popoverController.toggle(relativeTo: sender)
    }

    func showFromHotkey() {
        guard let button = statusItem.button else { return }
        popoverController.show(relativeTo: button)
    }
}
