import Foundation

/// Bridge so SwiftUI chrome (the smart-bullets picker, mode toggle) can drive
/// the UIKit editor. The text view's coordinator wires these closures up.
final class EditorActions: ObservableObject {
    var insertAtCaret: ((String) -> Void)?
    var focus: (() -> Void)?
}

/// Lets chrome reach the live `EditorActions` instance without threading it
/// through every initializer.
final class EditorActionsHolder {
    static let shared = EditorActionsHolder()
    let actions = EditorActions()
    private init() {}
}
