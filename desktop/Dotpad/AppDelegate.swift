import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = DotStore()
    private var statusItemController: StatusItemController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Agent app: no Dock icon, lives in the menu bar only.
        NSApp.setActivationPolicy(.accessory)

        statusItemController = StatusItemController(store: store)

        let prefs = Preferences.shared
        HotKeyManager.shared.onTrigger = { [weak self] in self?.statusItemController.showFromHotkey() }
        HotKeyManager.shared.register(
            keyCode: UInt32(prefs.hotKeyCode),
            modifiers: UInt32(prefs.hotKeyModifiers)
        )

        if ProcessInfo.processInfo.environment["DOTPAD_AUTOSHOW"] != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.statusItemController.showFromHotkey()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.flushSave()
    }
}
