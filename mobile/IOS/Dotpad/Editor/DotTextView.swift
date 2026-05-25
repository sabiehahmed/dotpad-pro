import SwiftUI
import UIKit

/// SwiftUI wrapper around a `UITextView`. Owns rich/plain rendering, binds
/// edits back to the `DotStore`, implements smart-bullet continuation, and
/// toggling checkbox-style bullets on tap.
struct DotTextView: UIViewRepresentable {
    @ObservedObject var store: DotStore
    @ObservedObject var actions: EditorActions
    @ObservedObject var prefs: Preferences
    let isDark: Bool

    func makeCoordinator() -> Coordinator { Coordinator(store: store, actions: actions, prefs: prefs) }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.backgroundColor = .clear
        tv.alwaysBounceVertical = true
        tv.keyboardDismissMode = .interactive
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 24, right: 14)
        tv.autocorrectionType = prefs.autocorrect ? .yes : .no
        tv.smartDashesType = prefs.smartDashes ? .yes : .no
        tv.smartQuotesType = .no
        tv.spellCheckingType = prefs.autocorrect ? .yes : .no
        tv.allowsEditingTextAttributes = false

        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        tap.delegate = context.coordinator
        tv.addGestureRecognizer(tap)

        context.coordinator.textView = tv
        context.coordinator.applyContent(store.activeContent, isDark: isDark)
        context.coordinator.wireActions()
        context.coordinator.currentDotId = store.activeDotId
        context.coordinator.currentMode = store.activeDot?.mode ?? .rich
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        let coord = context.coordinator
        let dotChanged = coord.currentDotId != store.activeDotId
        let modeChanged = coord.currentMode != (store.activeDot?.mode ?? .rich)
        let themeChanged = coord.isDark != isDark

        tv.autocorrectionType = prefs.autocorrect ? .yes : .no
        tv.smartDashesType = prefs.smartDashes ? .yes : .no
        tv.spellCheckingType = prefs.autocorrect ? .yes : .no

        if dotChanged || themeChanged || modeChanged {
            coord.currentDotId = store.activeDotId
            coord.currentMode = store.activeDot?.mode ?? .rich
            let content = (dotChanged || modeChanged)
                ? store.activeContent
                : NSAttributedString(attributedString: tv.attributedText)
            coord.applyContent(content, isDark: isDark)
        }
        coord.isDark = isDark
    }

    static func font(for mode: TextMode, size: CGFloat) -> UIFont {
        switch mode {
        case .rich: return .systemFont(ofSize: size)
        case .plain: return .monospacedSystemFont(ofSize: size - 1, weight: .regular)
        }
    }

    // MARK: Coordinator

    final class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        let store: DotStore
        let actions: EditorActions
        let prefs: Preferences
        weak var textView: UITextView?
        var currentDotId: UUID?
        var currentMode: TextMode = .rich
        var isDark: Bool = true

        init(store: DotStore, actions: EditorActions, prefs: Preferences) {
            self.store = store
            self.actions = actions
            self.prefs = prefs
        }

        private var fontSize: CGFloat { CGFloat(prefs.fontSize.rawValue) }

        func wireActions() {
            actions.insertAtCaret = { [weak self] text in
                guard let self, let tv = self.textView else { return }
                let sel = tv.selectedRange
                let attr = NSAttributedString(string: text, attributes: tv.typingAttributes)
                tv.textStorage.replaceCharacters(in: sel, with: attr)
                tv.selectedRange = NSRange(location: sel.location + (text as NSString).length, length: 0)
                self.textViewDidChange(tv)
            }
            actions.focus = { [weak self] in self?.textView?.becomeFirstResponder() }
        }

        func applyContent(_ content: NSAttributedString, isDark: Bool) {
            guard let tv = textView else { return }
            self.isDark = isDark
            let mode = store.activeDot?.mode ?? .rich
            let font = DotTextView.font(for: mode, size: fontSize)
            let defaultColor: UIColor = isDark ? .white : UIColor(white: 0.12, alpha: 1)
            tv.tintColor = isDark ? .white : .black

            if mode == .rich {
                tv.attributedText = content
                tv.typingAttributes = [.font: font, .foregroundColor: defaultColor]
                // Repaint base color/font for runs without explicit attrs.
                let full = NSRange(location: 0, length: tv.textStorage.length)
                tv.textStorage.enumerateAttribute(.foregroundColor, in: full) { value, range, _ in
                    if value == nil {
                        tv.textStorage.addAttribute(.foregroundColor, value: defaultColor, range: range)
                    }
                }
            } else {
                tv.attributedText = NSAttributedString(
                    string: content.string,
                    attributes: [.font: font, .foregroundColor: defaultColor]
                )
                tv.typingAttributes = [.font: font, .foregroundColor: defaultColor]
                highlightIfNeeded()
            }
        }

        /// Applies Markdown color highlights in plain mode.
        func highlightIfNeeded() {
            guard let tv = textView, store.activeDot?.mode == .plain else { return }
            let base = DotTextView.font(for: .plain, size: fontSize)
            let baseColor: UIColor = isDark ? .white : UIColor(white: 0.12, alpha: 1)
            let accent: UIColor = isDark
                ? UIColor(red: 0.85, green: 0.72, blue: 0.36, alpha: 1)
                : UIColor(red: 0.55, green: 0.44, blue: 0.17, alpha: 1)
            let sel = tv.selectedRange
            MarkdownHighlighter.apply(
                to: tv.textStorage, baseFont: base, baseColor: baseColor,
                accent: accent, linkColor: .systemBlue,
                enabled: prefs.colorHighlights
            )
            tv.selectedRange = sel
        }

        // MARK: Editing → store

        func textViewDidChange(_ textView: UITextView) {
            highlightIfNeeded()
            store.updateActiveContent(NSAttributedString(attributedString: textView.attributedText))
        }

        // MARK: Return / smart-bullet handling

        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {
            guard text == "\n" else { return true }
            let line = currentLine(textView, at: range.location)
            let markers = SmartBullets.allMarkers(from: prefs.smartBulletPairs)
            switch SmartBullets.handleReturn(line: line.text, markers: markers) {
            case .none:
                return true
            case .continueList(let insert):
                let attr = NSAttributedString(string: insert, attributes: textView.typingAttributes)
                textView.textStorage.replaceCharacters(in: range, with: attr)
                let newLoc = range.location + (insert as NSString).length
                textView.selectedRange = NSRange(location: newLoc, length: 0)
                textViewDidChange(textView)
                return false
            case .clearLine(let prefixLength):
                let clearRange = NSRange(location: line.range.location, length: prefixLength)
                textView.textStorage.replaceCharacters(in: clearRange, with: "")
                textView.selectedRange = NSRange(location: line.range.location, length: 0)
                textViewDidChange(textView)
                return false
            }
        }

        private func currentLine(_ tv: UITextView, at location: Int) -> (range: NSRange, text: String) {
            let ns = tv.text as NSString
            let loc = min(location, ns.length)
            let lineRange = ns.lineRange(for: NSRange(location: loc, length: 0))
            var text = ns.substring(with: lineRange)
            if text.hasSuffix("\n") { text.removeLast() }
            return (lineRange, text)
        }

        // MARK: Tap-to-toggle bullet

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let tv = textView else { return }
            let point = gesture.location(in: tv)
            // TextKit2-safe hit-test (avoids touching layoutManager, which would
            // force the text view into TextKit1 compatibility mode).
            guard let pos = tv.closestPosition(to: point) else { return }
            let charIndex = tv.offset(from: tv.beginningOfDocument, to: pos)

            let ns = tv.text as NSString
            if charIndex < ns.length, toggleBullet(tv, ns: ns, charIndex: charIndex) {
                return
            }
            placeCaret(tv, at: charIndex)
        }

        private func placeCaret(_ tv: UITextView, at index: Int) {
            if !tv.isFirstResponder { tv.becomeFirstResponder() }
            let clamped = min(index, (tv.text as NSString).length)
            tv.selectedRange = NSRange(location: clamped, length: 0)
        }

        @discardableResult
        private func toggleBullet(_ tv: UITextView, ns: NSString, charIndex: Int) -> Bool {
            let lineRange = ns.lineRange(for: NSRange(location: charIndex, length: 0))
            var lineText = ns.substring(with: lineRange)
            if lineText.hasSuffix("\n") { lineText.removeLast() }

            let pairs = prefs.smartBulletPairs
            let markers = SmartBullets.allMarkers(from: pairs)
            guard let bullet = SmartBullets.detect(line: lineText, using: markers) else { return false }

            let indentLen = (bullet.indent as NSString).length
            let markerLen = (bullet.marker as NSString).length
            let clickOffset = charIndex - lineRange.location
            guard clickOffset < indentLen + markerLen else { return false }

            let toggleDict = SmartBullets.togglePairs(from: pairs)
            guard let toggled = toggleDict[bullet.marker] else { return false }

            let markerRange = NSRange(location: lineRange.location + indentLen, length: markerLen)
            let attrs = tv.typingAttributes
            tv.textStorage.replaceCharacters(in: markerRange, with: NSAttributedString(string: toggled, attributes: attrs))
            textViewDidChange(tv)
            if prefs.hapticFeedback {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            return true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
    }
}
