import SwiftUI
import AppKit

/// SwiftUI wrapper around an `NSTextView`. Owns rich/plain rendering, binds
/// edits back to the `DotStore`, and implements smart-bullet continuation.
struct DotTextView: NSViewRepresentable {
    @ObservedObject var store: DotStore
    @ObservedObject var actions: EditorActions
    let isDark: Bool

    func makeCoordinator() -> Coordinator { Coordinator(store: store, actions: actions) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = DotNSTextView.makeScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true

        guard let textView = scroll.documentView as? NSTextView else { return scroll }
        textView.delegate = context.coordinator
        textView.isRichText = store.activeDot?.mode == .rich
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.textContainerInset = NSSize(width: 18, height: 16)
        textView.font = Self.font(for: store.activeDot?.mode ?? .rich)

        context.coordinator.textView = textView
        context.coordinator.applyContent(store.activeContent, isDark: isDark)
        context.coordinator.wireActions()
        context.coordinator.currentDotId = store.activeDotId
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let textView = scroll.documentView as? NSTextView else { return }
        let coord = context.coordinator
        // Reload when the active dot changed (switch / add / remove / mode)
        // or when the theme flipped — both require recoloring the text.
        let dotChanged = coord.currentDotId != store.activeDotId
        let themeChanged = coord.isDark != isDark
        if dotChanged || themeChanged {
            coord.currentDotId = store.activeDotId
            textView.isRichText = store.activeDot?.mode == .rich
            textView.font = Self.font(for: store.activeDot?.mode ?? .rich)
            // On a pure theme flip keep the live edits; reapply over current text.
            let content = dotChanged ? store.activeContent : NSAttributedString(attributedString: textView.attributedString())
            coord.applyContent(content, isDark: isDark)
        }
        coord.isDark = isDark
        textView.insertionPointColor = isDark ? .white : .black
    }

    static func font(for mode: TextMode) -> NSFont {
        switch mode {
        case .rich: return .systemFont(ofSize: 14)
        case .plain: return .monospacedSystemFont(ofSize: 13.5, weight: .regular)
        }
    }

    // MARK: Coordinator

    final class Coordinator: NSObject, NSTextViewDelegate {
        let store: DotStore
        let actions: EditorActions
        weak var textView: NSTextView?
        var currentDotId: UUID?
        var isDark: Bool = true

        init(store: DotStore, actions: EditorActions) {
            self.store = store
            self.actions = actions
        }

        func wireActions() {
            actions.insertAtCaret = { [weak self] text in
                guard let tv = self?.textView else { return }
                if tv.shouldChangeText(in: tv.selectedRange(), replacementString: text) {
                    tv.insertText(text, replacementRange: tv.selectedRange())
                    tv.didChangeText()
                }
            }
            actions.focus = { [weak self] in self?.textView?.window?.makeFirstResponder(self?.textView) }
        }

        func applyContent(_ content: NSAttributedString, isDark: Bool) {
            guard let tv = textView else { return }
            self.isDark = isDark
            // Appearance drives the adaptive default text color (labelColor),
            // so default-colored text flips with the theme automatically.
            tv.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
            let mode = store.activeDot?.mode ?? .rich
            let font = DotTextView.font(for: mode)
            let defaultColor: NSColor = isDark ? .white : NSColor(white: 0.12, alpha: 1)

            if mode == .rich {
                // Preserve stored attributes (bold, heading color). Only set the
                // base text color / font, leaving explicit per-run attrs intact.
                tv.textStorage?.setAttributedString(content)
                tv.typingAttributes = [.font: font, .foregroundColor: defaultColor]
            } else {
                tv.string = content.string
                tv.font = font
                tv.textColor = defaultColor
                tv.typingAttributes = [.font: font, .foregroundColor: defaultColor]
                highlightIfNeeded()
            }
        }

        /// Applies Markdown color highlights in plain mode (Tot feature).
        func highlightIfNeeded() {
            guard let tv = textView,
                  store.activeDot?.mode == .plain,
                  let storage = tv.textStorage else { return }
            let base = DotTextView.font(for: .plain)
            let baseColor: NSColor = isDark ? .white : NSColor(white: 0.12, alpha: 1)
            let accent: NSColor = isDark
                ? NSColor(calibratedRed: 0.85, green: 0.72, blue: 0.36, alpha: 1)
                : NSColor(calibratedRed: 0.55, green: 0.44, blue: 0.17, alpha: 1)
            let sel = tv.selectedRange()
            MarkdownHighlighter.apply(
                to: storage, baseFont: base, baseColor: baseColor,
                accent: accent, linkColor: .systemBlue,
                enabled: Preferences.shared.colorHighlights
            )
            tv.setSelectedRange(sel)
        }

        // MARK: Editing → store

        func textDidChange(_ notification: Notification) {
            guard let tv = textView else { return }
            highlightIfNeeded()
            let snapshot = NSAttributedString(attributedString: tv.attributedString())
            store.updateActiveContent(snapshot)
        }

        // MARK: Smart-bullet key handling

        func textView(_ textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            switch selector {
            case #selector(NSResponder.insertNewline(_:)):
                return handleReturn(textView)
            case #selector(NSResponder.insertTab(_:)):
                return handleIndent(textView)
            case #selector(NSResponder.insertBacktab(_:)):
                return handleOutdent(textView)
            default:
                return false
            }
        }

        private func currentLine(_ tv: NSTextView) -> (range: NSRange, text: String) {
            let ns = tv.string as NSString
            let sel = tv.selectedRange()
            let lineRange = ns.lineRange(for: NSRange(location: sel.location, length: 0))
            var text = ns.substring(with: lineRange)
            if text.hasSuffix("\n") { text.removeLast() }
            return (lineRange, text)
        }

        private func handleReturn(_ tv: NSTextView) -> Bool {
            let line = currentLine(tv)
            let markers = SmartBullets.allMarkers(from: Preferences.shared.smartBulletPairs)
            switch SmartBullets.handleReturn(line: line.text, markers: markers) {
            case .none:
                return false
            case .continueList(let insert):
                if tv.shouldChangeText(in: tv.selectedRange(), replacementString: insert) {
                    tv.insertText(insert, replacementRange: tv.selectedRange())
                    tv.didChangeText()
                }
                return true
            case .clearLine(let prefixLength):
                let clearRange = NSRange(location: line.range.location, length: prefixLength)
                if tv.shouldChangeText(in: clearRange, replacementString: "") {
                    tv.replaceCharacters(in: clearRange, with: "")
                    tv.didChangeText()
                }
                return true
            }
        }

        private func handleIndent(_ tv: NSTextView) -> Bool {
            let line = currentLine(tv)
            let markers = SmartBullets.allMarkers(from: Preferences.shared.smartBulletPairs)
            guard SmartBullets.detect(line: line.text, using: markers) != nil else { return false }
            let at = NSRange(location: line.range.location, length: 0)
            if tv.shouldChangeText(in: at, replacementString: "\t") {
                tv.replaceCharacters(in: at, with: "\t")
                tv.didChangeText()
            }
            return true
        }

        private func handleOutdent(_ tv: NSTextView) -> Bool {
            let line = currentLine(tv)
            guard line.text.first == "\t" || line.text.hasPrefix("  ") else { return false }
            let removeLen = line.text.first == "\t" ? 1 : 2
            let range = NSRange(location: line.range.location, length: removeLen)
            if tv.shouldChangeText(in: range, replacementString: "") {
                tv.replaceCharacters(in: range, with: "")
                tv.didChangeText()
            }
            return true
        }
    }
}

// MARK: - DotNSTextView

private final class DotNSTextView: NSTextView {
    static func makeScrollView() -> NSScrollView {
        let textContainer = NSTextContainer(containerSize: NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        ))
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let storage = NSTextStorage()
        storage.addLayoutManager(layoutManager)

        let textView = DotNSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)

        let scroll = NSScrollView()
        scroll.documentView = textView
        return scroll
    }

    override func mouseDown(with event: NSEvent) {
        if tryToggleBullet(event: event) { return }
        super.mouseDown(with: event)
    }

    private func tryToggleBullet(event: NSEvent) -> Bool {
        let point = convert(event.locationInWindow, from: nil)
        guard let lm = layoutManager, let tc = textContainer else { return false }
        let inset = textContainerInset
        let adjustedPoint = NSPoint(x: point.x - inset.width, y: point.y - inset.height)
        let charIndex = lm.characterIndex(
            for: adjustedPoint, in: tc,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        let ns = string as NSString
        guard charIndex < ns.length else { return false }

        let lineRange = ns.lineRange(for: NSRange(location: charIndex, length: 0))
        var lineText = ns.substring(with: lineRange)
        if lineText.hasSuffix("\n") { lineText.removeLast() }

        let pairs = Preferences.shared.smartBulletPairs
        let markers = SmartBullets.allMarkers(from: pairs)
        guard let bullet = SmartBullets.detect(line: lineText, using: markers) else { return false }

        // Only toggle when click lands within the marker region (NSString-safe lengths)
        let indentNSLen = (bullet.indent as NSString).length
        let markerNSLen = (bullet.marker as NSString).length
        let clickOffset = charIndex - lineRange.location
        guard clickOffset < indentNSLen + markerNSLen else { return false }

        let toggleDict = SmartBullets.togglePairs(from: pairs)
        guard let toggled = toggleDict[bullet.marker] else { return false }

        let markerRange = NSRange(location: lineRange.location + indentNSLen, length: markerNSLen)
        if shouldChangeText(in: markerRange, replacementString: toggled) {
            replaceCharacters(in: markerRange, with: toggled)
            didChangeText()
        }
        return true
    }
}
