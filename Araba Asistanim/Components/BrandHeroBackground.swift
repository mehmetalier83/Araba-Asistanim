import SwiftUI

/// The gradient hero surface (vehicle headers, the empty-garage card): the brand
/// gradient on a diagonal with a soft light bloom in the top-trailing corner and
/// a faint car glyph. Same in light and dark mode — it is a brand surface.
struct BrandHeroBackground: View {
    var showsCarGlyph = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient.mascot(startPoint: .topLeading, endPoint: .bottomTrailing)

            RadialGradient(
                colors: [.white.opacity(0.30), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 240
            )

            if showsCarGlyph {
                Image(systemName: "car.side.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.white.opacity(0.14))
                    .offset(x: 24, y: 10)
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    BrandHeroBackground()
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .padding()
}
