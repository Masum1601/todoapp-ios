import SwiftUI
import FirebaseCore

// MARK: - 🎯 Masum's TaskFocus iOS Application
// Main entry point initializing Firebase Core

@main
struct MasumTodoApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
