import SwiftUI

@main
struct DotpadApp: App {
    @StateObject private var store = DotStore()
    @StateObject private var prefs = Preferences.shared

    var body: some Scene {
        WindowGroup {
            ContentView(store: store, prefs: prefs)
        }
    }
}
