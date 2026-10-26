import SwiftUI

/// One vehicle in the Araçlar list: a gradient car tile, the name, year and
/// mileage, spec chips and a chevron. The NavigationLink is attached by the list.
struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "car.side.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient.mascot(), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(vehicle.displayName)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("\(vehicle.year.description) · \(vehicle.mileageKm.formattedMileage())")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 6) {
                    chip(vehicle.fuelType.displayName, systemImage: "fuelpump.fill")
                    if !vehicle.transmission.isEmpty {
                        chip(vehicle.transmission, systemImage: "gearshape.fill")
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(AppSpacing.md)
        .appCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
        .accessibilityAddTraits(.isButton)
    }

    private func chip(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppTheme.primary)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.primarySubtle, in: Capsule())
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        VehicleCardView(vehicle: PreviewData.vehicles[0])
        VehicleCardView(vehicle: PreviewData.vehicles[1])
    }
    .padding()
}

#Preview("Dark") {
    VStack(spacing: AppSpacing.sm) {
        VehicleCardView(vehicle: PreviewData.vehicles[0])
        VehicleCardView(vehicle: PreviewData.vehicles[1])
    }
    .padding()
    .preferredColorScheme(.dark)
}
