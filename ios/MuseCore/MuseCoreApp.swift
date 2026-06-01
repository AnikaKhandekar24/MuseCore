import SwiftUI

@main
struct MuseCoreApp: App {
    @StateObject private var viewModel = MusicViewModel()

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(viewModel)
        }
    }
}
