import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var viewModel: MusicViewModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                MuseTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        SectionHeader(
                            title: "Music Insights",
                            subtitle: "A tiny dashboard for your listening personality."
                        )

                        if let insights = viewModel.insights {
                            LazyVGrid(columns: columns, spacing: 14) {
                                metricCard(title: "Top Mood", value: insights.topMood.capitalized, icon: "face.smiling")
                                metricCard(title: "Top Genre", value: insights.topGenre, icon: "guitars")
                                metricCard(title: "Favorites", value: "\(insights.favoriteCount)", icon: "heart.fill")
                                metricCard(title: "Total Plays", value: "\(insights.totalPlays)", icon: "play.circle.fill")
                            }

                            SectionHeader(title: "Most Played", subtitle: "Your strongest repeat listens.")

                            ForEach(insights.mostPlayed) { song in
                                SongCardView(song: song, showPlayButton: false) {
                                    Task { await viewModel.play(song) }
                                } onFavorite: {
                                    Task { await viewModel.toggleFavorite(song) }
                                }
                            }

                            breakdown(title: "Mood Breakdown", values: insights.moodBreakdown)
                            breakdown(title: "Genre Breakdown", values: insights.genreBreakdown)
                        } else {
                            ProgressView("Loading insights")
                                .tint(MuseTheme.ink)
                                .softCard()
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Insights")
            .task {
                if viewModel.insights == nil {
                    await viewModel.loadInitialData()
                }
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(MuseTheme.lavender)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(MuseTheme.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(MuseTheme.softText)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .softCard()
    }

    private func breakdown(title: String, values: [String: Int]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(MuseTheme.ink)

            ForEach(values.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                HStack {
                    Text(key.capitalized)
                        .foregroundStyle(MuseTheme.softText)
                    Spacer()
                    Text("\(value)")
                        .fontWeight(.semibold)
                        .foregroundStyle(MuseTheme.ink)
                }
            }
        }
        .softCard()
    }
}
