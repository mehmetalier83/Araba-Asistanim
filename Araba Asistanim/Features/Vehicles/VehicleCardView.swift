import SwiftUI

/// A compact row representing one vehicle in a list. For the single-vehicle
/// hero treatment used on Home, see VehicleHeroCard — a list row and a hero
/// element have different jobs and are styled independently.
struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "car.side.fill")
                .font(.system(size: AppSizes.iconMedium))
                .foregroundStyle(AppTheme.primary)
                .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                .background(AppTheme.primarySubtle)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.displayName)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("\(vehicle.year.description) · \(vehicle.mileageKm.formattedMileage())")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
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
