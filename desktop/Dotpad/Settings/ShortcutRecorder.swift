import SwiftUI
import Carbon.HIToolbox

/// Captures a global shortcut: click to arm, press a combo to record.
struct ShortcutRecorder: View {
    @ObservedObject var prefs: Preferences
    @State private var recording = false
    @State private var monitor: Any?

    var body: some View {
        Button(action: toggle) {
            Text(recording ? "Type shortcut…" : display)
                .frame(minWidth: 130)
        }
        .onDisappear(perform: stop)
    }

    private var display: String {
        guard prefs.hotKeyCode != 0 else { return "Record Shortcut" }
        return Self.string(keyCode: UInt32(prefs.hotKeyCode), carbonMods: UInt32(prefs.hotKeyModifiers))
    }

    private func toggle() {
        if recording { stop() } else { start() }
    }

    private func start() {
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let carbon = Self.carbonModifiers(event.modifierFlags)
            guard carbon != 0 else { return event } // require a modifier
            prefs.hotKeyCode = Int(event.keyCode)
            prefs.hotKeyModifiers = Int(carbon)
            HotKeyManager.shared.register(keyCode: UInt32(event.keyCode), modifiers: carbon)
            stop()
            return nil
        }
    }

    private func stop() {
        recording = false
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }

    // MARK: Modifier mapping

    static func carbonModifiers(_ flags: NSEvent.ModifierFlags) -> UInt32 {
        var c: UInt32 = 0
        if flags.contains(.command) { c |= UInt32(cmdKey) }
        if flags.contains(.shift) { c |= UInt32(shiftKey) }
        if flags.contains(.option) { c |= UInt32(optionKey) }
        if flags.contains(.control) { c |= UInt32(controlKey) }
        return c
    }

    static func string(keyCode: UInt32, carbonMods: UInt32) -> String {
        var s = ""
        if carbonMods & UInt32(controlKey) != 0 { s += "⌃" }
        if carbonMods & UInt32(optionKey) != 0 { s += "⌥" }
        if carbonMods & UInt32(shiftKey) != 0 { s += "⇧" }
        if carbonMods & UInt32(cmdKey) != 0 { s += "⌘" }
        s += keyName(keyCode)
        return s
    }

    static func keyName(_ code: UInt32) -> String {
        let map: [UInt32: String] = [
            49: "Space", 36: "↩", 48: "⇥", 51: "⌫", 53: "Esc",
            123: "←", 124: "→", 125: "↓", 126: "↑",
        ]
        if let n = map[code] { return n }
        let layout = TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue(),
                                               kTISPropertyUnicodeKeyLayoutData)
        guard let data = layout else { return "?" }
        let cfData = unsafeBitCast(data, to: CFData.self)
        let keyLayout = unsafeBitCast(CFDataGetBytePtr(cfData), to: UnsafePointer<UCKeyboardLayout>.self)
        var deadKeys: UInt32 = 0
        var chars = [UniChar](repeating: 0, count: 4)
        var length = 0
        UCKeyTranslate(keyLayout, UInt16(code), UInt16(kUCKeyActionDisplay), 0,
                       UInt32(LMGetKbdType()), UInt32(kUCKeyTranslateNoDeadKeysBit),
                       &deadKeys, 4, &length, &chars)
        return String(utf16CodeUnits: chars, count: length).uppercased()
    }
}
