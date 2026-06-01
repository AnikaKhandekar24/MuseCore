import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject private var viewModel: MusicViewModel
    let song: Song

    var displayedSong: Song {
        viewModel.songs.first(where: { $0.id == song.id }) ?? song
    }

    var body: some View {
        ZStack {
            MuseTheme.background.ignoresSafeArea()

            VStack(spacing: 26) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [MuseTheme.lavender, MuseTheme.blush, MuseTheme.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 280)
                        .shadow(color: MuseTheme.lavender.opacity(0.35), radius: 28, x: 0, y: 20)

                    Image(systemName: "music.note")
                        .font(.system(size: 92, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text(displayedSong.songName)
                        .font(.largeTitle.bold())
                        .foregroundStyle(MuseTheme.ink)
                        .multilineTextAlignment(.center)

                    Text(displayedSong.artist)
                        .font(.title3)
                        .foregroundStyle(MuseTheme.softText)

                    Text("\(displayedSong.genre) • \(displayedSong.mood.capitalized) • \(displayedSong.energy)% energy")
                        .font(.callout)
                        .foregroundStyle(MuseTheme.softText)
                }

                HStack(spacing: 24) {
                    Button {
                        Task { await viewModel.skip(displayedSong) }
                    } label: {
                        Image(systemName: "forward.end.fill")
                            .controlIconStyle()
                    }

                    Button {
                        Task { await viewModel.play(displayedSong) }
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 76, height: 76)
                            .background(MuseTheme.ink)
                            .clipShape(Circle())
                    }

                    Button {
                        Task { await viewModel.toggleFavorite(displayedSong) }
                    } label: {
                        Image(systemName: displayedSong.favorite ? "heart.fill" : "heart")
                            .controlIconStyle(active: displayedSong.favorite)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension Image {
    func controlIconStyle(active: Bool = false) -> some View {
        font(.system(size: 24, weight: .semibold))
            .foregroundStyle(active ? MuseTheme.blush : MuseTheme.ink)
            .frame(width: 58, height: 58)
            .background(.white.opacity(0.72))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}
