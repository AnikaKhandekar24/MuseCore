import Foundation

@MainActor
final class MusicViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var recommendations: [Song] = []
    @Published var playlist: [Song] = []
    @Published var favorites: [Song] = []
    @Published var history: [Song] = []
    @Published var insights: InsightResponse?
    @Published var selectedMood = "focused"
    @Published var nowPlaying: Song?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private var skippedSongIDs: [Int] = []

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let songsTask = api.fetchSongs()
            async let favoritesTask = api.fetchFavorites()
            async let historyTask = api.fetchHistory()
            async let insightsTask = api.fetchInsights()

            songs = try await songsTask
            favorites = try await favoritesTask
            history = try await historyTask
            insights = try await insightsTask
            recommendations = try await api.recommend(
                mood: selectedMood,
                energy: 35,
                recentlyPlayed: history.map(\.id),
                skippedSongs: skippedSongIDs
            )
        } catch {
            errorMessage = "Could not connect to MuseCore API. Start the FastAPI server and try again."
        }
    }

    func generatePlaylist(for mood: String, studyMode: Bool) async {
        selectedMood = mood
        isLoading = true
        defer { isLoading = false }

        do {
            let energy = moodOptions.first { $0.name == mood }?.targetEnergy
            playlist = try await api.moodPlaylist(mood: mood, studyMode: studyMode)
            recommendations = try await api.recommend(
                mood: mood,
                energy: energy,
                recentlyPlayed: history.map(\.id),
                skippedSongs: skippedSongIDs
            )
            errorMessage = nil
        } catch {
            errorMessage = "Playlist generation failed. Check that the backend is running."
        }
    }

    func play(_ song: Song) async {
        nowPlaying = song
        do {
            let updated = try await api.trackHistory(songID: song.id)
            updateSong(updated)
            history = try await api.fetchHistory()
            insights = try await api.fetchInsights()
        } catch {
            errorMessage = "Could not update listening history."
        }
    }

    func skip(_ song: Song) async {
        skippedSongIDs.append(song.id)
        do {
            _ = try await api.trackHistory(songID: song.id, skipped: true)
            recommendations = try await api.recommend(
                mood: selectedMood,
                energy: moodOptions.first { $0.name == selectedMood }?.targetEnergy,
                recentlyPlayed: history.map(\.id),
                skippedSongs: skippedSongIDs
            )
        } catch {
            errorMessage = "Could not record skipped song."
        }
    }

    func toggleFavorite(_ song: Song) async {
        do {
            let updated = try await api.setFavorite(songID: song.id, favorite: !song.favorite)
            updateSong(updated)
            favorites = try await api.fetchFavorites()
            insights = try await api.fetchInsights()
        } catch {
            errorMessage = "Could not update favorites."
        }
    }

    private func updateSong(_ updated: Song) {
        replace(&songs, with: updated)
        replace(&recommendations, with: updated)
        replace(&playlist, with: updated)
        replace(&favorites, with: updated)
        replace(&history, with: updated)
        if nowPlaying?.id == updated.id {
            nowPlaying = updated
        }
    }

    private func replace(_ list: inout [Song], with updated: Song) {
        if let index = list.firstIndex(where: { $0.id == updated.id }) {
            list[index] = updated
        }
    }
}
