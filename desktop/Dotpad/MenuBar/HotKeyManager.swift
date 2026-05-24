import AppKit
import Carbon.HIToolbox

/// Registers a single global hot key (Carbon) that invokes a callback —
/// used by the Control tab's "Show window" shortcut.
final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    var onTrigger: (() -> Void)?

    private let signature = OSType(0x44_4F_54_50) // 'DOTP'

    private init() { installHandler() }

    private func installHandler() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData -> OSStatus in
            let mgr = Unmanaged<HotKeyManager>.fromOpaque(userData!).takeUnretainedValue()
            mgr.onTrigger?()
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
    }

    /// keyCode/modifiers are Carbon values (modifiers e.g. cmdKey|shiftKey).
    func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()
        guard keyCode != 0 else { return }
        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: signature, id: 1)
        RegisterEventHotKey(keyCode, modifiers, id, GetApplicationEventTarget(), 0, &ref)
        hotKeyRef = ref
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
    }
}
