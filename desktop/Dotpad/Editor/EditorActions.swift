import AppKit

/// Bridge so SwiftUI chrome (the smart-bullets picker, mode toggle) can drive
/// the AppKit editor. The text view's coordinator wires these closures up.
final class EditorActions: ObservableObject {
    var insertAtCaret: ((String) -> Void)?
    var focus: (() -> Void)?
}
