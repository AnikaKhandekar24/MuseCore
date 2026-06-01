import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: MusicViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                MuseTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        header

                        if let message = viewModel.errorMessage {
                            Text(message)
                                .font(.callout)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(MuseTheme.blush)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        nowPlayingPreview

                        SectionHeader(
                            title: "Recommended for You",
                            subtitle: "Powered by your mood, favorites, skips, and recent plays."
                        )

                        ForEach(viewModel.recommendations) { song in
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
                    .padding(20)
                }
            }
            .navigationTitle("Home")
            .task {
                if viewModel.songs.isEmpty {
                    await viewModel.loadInitialData()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi, Anika")
                .font(.largeTitle.bold())
                .foregroundStyle(MuseTheme.ink)
            Text("What should MuseCore queue up today?")
                .font(.title3)
                .foregroundStyle(MuseTheme.softText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var nowPlayingPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Now Playing")
                .font(.headline)
                .foregroundStyle(MuseTheme.ink)

            if let song = viewModel.nowPlaying {
                HStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(MuseTheme.lavender)
                    VStack(alignment: .leading) {
                        Text(song.songName)
                            .font(.title3.bold())
                            .foregroundStyle(MuseTheme.ink)
                        Text(song.artist)
                            .foregroundStyle(MuseTheme.softText)
                    }
                    Spacer()
                }
            } else {
                Text("Pick a song to start building your listening history.")
                    .foregroundStyle(MuseTheme.softText)
            }
        }
        .softCard()
    }
}
