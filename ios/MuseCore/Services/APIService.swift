import Foundation

final class APIService {
    static let shared = APIService()

    // iOS Simulator can reach your Mac at localhost. Use your computer IP for a physical iPhone.
    var baseURL = URL(string: "http://127.0.0.1:8000")!

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private init() {}

    func fetchSongs() async throws -> [Song] {
        try await get("/songs")
    }

    func fetchFavorites() async throws -> [Song] {
        try await get("/favorites")
    }

    func fetchHistory() async throws -> [Song] {
        try await get("/history")
    }

    func fetchInsights() async throws -> InsightResponse {
        try await get("/insights")
    }

    func recommend(mood: String?, energy: Int?, recentlyPlayed: [Int], skippedSongs: [Int]) async throws -> [Song] {
        let body: [String: Any?] = [
            "mood": mood,
            "energy_level": energy,
            "recently_played": recentlyPlayed,
            "skipped_songs": skippedSongs,
            "limit": 8
        ]
        return try await post("/recommend", body: body.compactMapValues { $0 })
    }

    func moodPlaylist(mood: String, studyMode: Bool) async throws -> [Song] {
        try await post("/mood-playlist", body: [
            "mood": mood,
            "study_mode": studyMode,
            "limit": 10
        ])
    }

    func setFavorite(songID: Int, favorite: Bool) async throws -> Song {
        try await post("/favorites", body: [
            "song_id": songID,
            "favorite": favorite
        ])
    }

    func trackHistory(songID: Int, skipped: Bool = false) async throws -> Song {
        try await post("/history", body: [
            "song_id": songID,
            "skipped": skipped
        ])
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try decoder.decode(T.self, from: data)
    }

    private func post<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return try decoder.decode(T.self, from: data)
    }

    private func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
}
