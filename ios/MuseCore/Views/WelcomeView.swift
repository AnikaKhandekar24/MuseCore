import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var viewModel: MusicViewModel
    @State private var showApp = false

    var body: some View {
        Group {
            if showApp {
                MainTabView()
            } else {
                NavigationStack {
                    ZStack {
                        MuseTheme.background.ignoresSafeArea()

                        VStack(spacing: 28) {
                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(MuseTheme.blush.opacity(0.45))
                                    .frame(width: 190, height: 190)
                                Circle()
                                    .fill(MuseTheme.mint.opacity(0.55))
                                    .frame(width: 135, height: 135)
                                    .offset(x: 54, y: 34)
                                Image(systemName: "music.quarternote.3")
                                    .font(.system(size: 76, weight: .bold))
                                    .foregroundStyle(MuseTheme.ink)
                            }

                            VStack(spacing: 12) {
                                Text("MuseCore")
                                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                                    .foregroundStyle(MuseTheme.ink)
                                Text("A pastel music companion that learns your mood, favorites, energy, and listening patterns.")
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(MuseTheme.softText)
                                    .padding(.horizontal)
                            }

                            Button {
                                showApp = true
                            } label: {
                                Label("Start Listening", systemImage: "play.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(MuseTheme.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                            .padding(.horizontal, 32)

                            Spacer()
                        }
                    }
                    .task {
                        await viewModel.loadInitialData()
                    }
                }
            }
        }
    }
}
