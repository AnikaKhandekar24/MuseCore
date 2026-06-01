import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: MusicViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                MuseTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        SectionHeader(
                            title: "Favorites",
                            subtitle: "The songs shaping your recommendations most strongly."
                        )

                        if viewModel.favorites.isEmpty {
                            Text("Tap the heart on a song to add it here.")
                                .foregroundStyle(MuseTheme.softText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .softCard()
                        } else {
                            ForEach(viewModel.favorites) { song in
                                NavigationLink {
                                    NowPlayingView(song: song)
                                } label: {
                                    SongCardView(song: song) {
                                        Task { await viewModel.play(song) }
                                    } onFavorite: {
                                        Task { await viewModel.toggleFavorite(song) }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Favorites")
            .task {
                if viewModel.favorites.isEmpty {
                    await viewModel.loadInitialData()
                }
            }
        }
    }
}
