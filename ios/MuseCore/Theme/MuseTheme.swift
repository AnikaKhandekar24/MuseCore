import SwiftUI

enum MuseTheme {
    static let blush = Color(red: 1.00, green: 0.74, blue: 0.78)
    static let lavender = Color(red: 0.73, green: 0.68, blue: 0.96)
    static let mint = Color(red: 0.67, green: 0.91, blue: 0.82)
    static let butter = Color(red: 1.00, green: 0.89, blue: 0.55)
    static let ink = Color(red: 0.16, green: 0.16, blue: 0.24)
    static let softText = Color(red: 0.43, green: 0.42, blue: 0.54)
    static let panel = Color.white.opacity(0.78)

    static let background = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.95, blue: 0.91),
            Color(red: 0.91, green: 0.93, blue: 1.00),
            Color(red: 0.91, green: 1.00, blue: 0.96)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct SoftCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.07), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func softCard() -> some View {
        modifier(SoftCard())
    }
}
