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

                        Text(vehicle.year.description)
                            .font(AppTypography.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(vehicle.mileageKm.formattedMileage())
                            .font(AppTypography.heroValue)
                            .foregroundStyle(.white)

                        Text("Current mileage")
                            .font(AppTypography.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    HStack(spacing: 4) {
                        Text("View Vehicle")
                        Image(systemName: "chevron.right")
                    }
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white)
                }
                .padding(AppSpacing.lg)
            }
        }
        .buttonStyle(.appPressScale)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
        .accessibilityHint("View vehicle details")
    }

    private var backgroundSurface: some View {
        LinearGradient(
            colors: [
                Color(light: Color(hex: 0x24304A), dark: Color(hex: 0x141A26)),
                Color(light: Color(hex: 0x101624), dark: Color(hex: 0x05070C))
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
