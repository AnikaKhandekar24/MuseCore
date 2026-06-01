import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            MoodPickerView()
                .tabItem {
                    Label("Mood", systemImage: "face.smiling.fill")
                }

            PlaylistView()
                .tabItem {
                    Label("Playlist", systemImage: "music.note.list")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
        }
        .tint(MuseTheme.ink)
    }
}
