import SwiftUI

/// The Home dashboard's focal element: the user's featured vehicle. Deliberately
/// distinct from VehicleCardView (the compact list row used in the Vehicles tab) —
/// a hero element and a list row have different jobs and shouldn't share one
/// generic "card" treatment. Uses a subtle dark gradient surface with an abstract
/// automotive glyph rather than a stock photo, so it reads as premium regardless
/// of whether a real vehicle photo exists yet.
struct VehicleHeroCard: View {
    let vehicle: Vehicle
    let action: () -> Void

    /// The engine's leading displacement token (e.g. "2.0L" out of "2.0L Turbo I4"),
    /// for a compact spec line — the full string is still shown on Vehicle Detail.
    private var shortEngine: String {
        vehicle.engine.split(separator: " ").first.map(String.init) ?? vehicle.engine
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                backgroundSurface

                Image(systemName: "car.side.fill")
                    .font(.system(size: 108))
                    .foregroundStyle(.white.opacity(0.08))
                    .offset(x: 56, y: 8)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vehicle.displayName)
                            .font(AppTypography.title2)
                            .foregroundStyle(.white)

                        Text("\(vehicle.year.description) · \(shortEngine) · \(vehicle.fuelType.displayName)")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(vehicle.mileageKm.formattedMileage())
                            .font(AppTypography.heroValue)
                            .foregroundStyle(.white)

                        Text("Güncel kilometre")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    HStack(spacing: 4) {
                        Text("Aracı Görüntüle")
                        Image(systemName: "chevron.right")
                    }
                    .font(AppTypography.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(.white.opacity(0.16))
                    .clipShape(Capsule())
                }
                .padding(AppSpacing.lg)
            }
        }
        .buttonStyle(.appPressScale)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
        .accessibilityHint("Araç detaylarını gör")
    }

    private var backgroundSurface: some View {
        LinearGradient.graphiteSurface()
    }
}

#Preview {
    VehicleHeroCard(vehicle: PreviewData.featuredVehicle) {}
        .padding()
}

#Preview("Dark") {
    VehicleHeroCard(vehicle: PreviewData.featuredVehicle) {}
        .padding()
        .preferredColorScheme(.dark)
}
