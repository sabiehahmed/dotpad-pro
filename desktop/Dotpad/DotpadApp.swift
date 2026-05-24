import SwiftUI

@main
struct DotpadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Menu-bar agent app: no main window. Settings scene kept empty;
        // the popover is driven entirely by AppDelegate / StatusItemController.
        Settings {
            EmptyView()
        }
    }
}
