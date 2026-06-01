import SwiftUI

struct SongCardView: View {
    let song: Song
    var showPlayButton = true
    let onPlay: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(coverGradient)
                Image(systemName: song.studyFriendly ? "headphones.circle.fill" : "music.note")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(song.songName)
                    .font(.headline)
                    .foregroundStyle(MuseTheme.ink)
                    .lineLimit(1)

                Text("\(song.artist) • \(song.genre)")
                    .font(.subheadline)
                    .foregroundStyle(MuseTheme.softText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label(song.mood.capitalized, systemImage: "sparkle")
                    Label("\(song.energy)%", systemImage: "waveform")
                }
                .font(.caption)
                .foregroundStyle(MuseTheme.softText)
            }

            Spacer()

            Button(action: onFavorite) {
                Image(systemName: song.favorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(song.favorite ? MuseTheme.blush : MuseTheme.softText)
            }
            .buttonStyle(.plain)

            if showPlayButton {
                Button(action: onPlay) {
                    Image(systemName: "play.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(MuseTheme.ink)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .softCard()
    }

    private var coverGradient: LinearGradient {
        LinearGradient(
            colors: [MuseTheme.lavender, MuseTheme.blush, MuseTheme.mint],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
