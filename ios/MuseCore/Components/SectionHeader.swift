import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(MuseTheme.ink)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(MuseTheme.softText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
