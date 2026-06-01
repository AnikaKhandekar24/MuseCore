import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject private var viewModel: MusicViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                MuseTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        SectionHeader(
                            title: "\(viewModel.selectedMood.capitalized) Playlist",
                            subtitle: "A mood-matched mix sorted by favorites and plays."
                        )

                        if viewModel.playlist.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.playlist) { song in
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
            .navigationTitle("Playlist")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 46))
                .foregroundStyle(MuseTheme.lavender)
            Text("No playlist yet")
                .font(.title3.bold())
                .foregroundStyle(MuseTheme.ink)
            Text("Choose a mood to generate your first MuseCore playlist.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(MuseTheme.softText)
        }
        .frame(maxWidth: .infinity)
        .softCard()
    }
}
