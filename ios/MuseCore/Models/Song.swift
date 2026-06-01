import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: Int
    let songName: String
    let artist: String
    let genre: String
    let mood: String
    let energy: Int
    let language: String
    let studyFriendly: Bool
    var playCount: Int
    var favorite: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case songName = "song_name"
        case artist
        case genre
        case mood
        case energy
        case language
        case studyFriendly = "study_friendly"
        case playCount = "play_count"
        case favorite
    }
}

struct InsightResponse: Codable {
    let topMood: String
    let topGenre: String
    let favoriteCount: Int
    let totalPlays: Int
    let mostPlayed: [Song]
    let moodBreakdown: [String: Int]
    let genreBreakdown: [String: Int]

    enum CodingKeys: String, CodingKey {
        case topMood = "top_mood"
        case topGenre = "top_genre"
        case favoriteCount = "favorite_count"
        case totalPlays = "total_plays"
        case mostPlayed = "most_played"
        case moodBreakdown = "mood_breakdown"
        case genreBreakdown = "genre_breakdown"
    }
}

struct MoodOption: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let targetEnergy: Int
}

let moodOptions: [MoodOption] = [
    MoodOption(name: "calm", icon: "cloud.sun.fill", color: "Mint", targetEnergy: 30),
    MoodOption(name: "focused", icon: "book.closed.fill", color: "Lavender", targetEnergy: 35),
    MoodOption(name: "happy", icon: "sun.max.fill", color: "Butter", targetEnergy: 70),
    MoodOption(name: "energetic", icon: "bolt.fill", color: "Blush", targetEnergy: 90),
    MoodOption(name: "confident", icon: "sparkles", color: "Violet", targetEnergy: 85),
    MoodOption(name: "sad", icon: "moon.stars.fill", color: "Blue", targetEnergy: 25),
    MoodOption(name: "romantic", icon: "heart.fill", color: "Rose", targetEnergy: 55)
]
