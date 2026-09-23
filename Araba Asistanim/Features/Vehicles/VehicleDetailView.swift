import SwiftUI

/// A temporary vehicle detail screen. All fields are mock data in this phase.
struct VehicleDetailView: View {
    let vehicle: Vehicle

    private var details: [(label: String, value: String)] {
        [
            ("Brand", vehicle.make),
            ("Model", vehicle.model),
            ("Year", vehicle.year.description),
            ("Mileage", vehicle.mileageKm.formattedMileage()),
            ("Fuel Type", vehicle.fuelType.displayName),
            ("Engine", vehicle.engine),
            ("Transmission", vehicle.transmission)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: AppSizes.iconLarge * 1.5))
                        .foregroundStyle(AppTheme.primary)
                        .accessibilityHidden(true)

                    Text(vehicle.displayName)
                        .font(AppTypography.title)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity)

                CardView {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                            HStack {
                                Text(detail.label)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppTheme.textSecondary)
                                Spacer()
                                Text(detail.value)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                            .accessibilityElement(children: .combine)

                            if index < details.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppTheme.background)
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VehicleDetailView(vehicle: PreviewData.vehicles[0])
    }
}

#Preview("Dark") {
    NavigationStack {
        VehicleDetailView(vehicle: PreviewData.vehicles[0])
    }
    .preferredColorScheme(.dark)
}
