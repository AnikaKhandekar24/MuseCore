import SwiftUI

struct MoodPickerView: View {
    @EnvironmentObject private var viewModel: MusicViewModel
    @State private var studyMode = false

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
                            title: "Mood Picker",
                            subtitle: "Choose a feeling and MuseCore will shape a playlist around it."
                        )

                        Toggle(isOn: $studyMode) {
                            Label("Study-friendly only", systemImage: "book.fill")
                                .font(.headline)
                                .foregroundStyle(MuseTheme.ink)
                        }
                        .tint(MuseTheme.mint)
                        .softCard()

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(moodOptions) { mood in
                                Button {
                                    Task {
                                        await viewModel.generatePlaylist(for: mood.name, studyMode: studyMode)
                                    }
                                } label: {
                                    VStack(spacing: 12) {
                                        Image(systemName: mood.icon)
                                            .font(.system(size: 32, weight: .semibold))
                                        Text(mood.name.capitalized)
                                            .font(.headline)
                                        Text("\(mood.targetEnergy)% energy")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(MuseTheme.ink)
                                    .frame(maxWidth: .infinity, minHeight: 128)
                                    .background(cardColor(for: mood).opacity(viewModel.selectedMood == mood.name ? 0.85 : 0.46))
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        NavigationLink {
                            PlaylistView()
                        } label: {
                            Label("Open Playlist", systemImage: "music.note.list")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(MuseTheme.ink)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Mood")
        }
    }

    private func cardColor(for mood: MoodOption) -> Color {
        switch mood.name {
        case "calm": return MuseTheme.mint
        case "focused": return MuseTheme.lavender
        case "happy": return MuseTheme.butter
        case "energetic": return MuseTheme.blush
        case "confident": return Color(red: 0.78, green: 0.68, blue: 1.0)
        case "sad": return Color(red: 0.68, green: 0.82, blue: 1.0)
        default: return Color(red: 1.0, green: 0.70, blue: 0.80)
        }
    }
}
