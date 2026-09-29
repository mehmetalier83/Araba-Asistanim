import SwiftUI

/// A temporary vehicle detail screen. All fields are mock data in this phase.
struct VehicleDetailView: View {
    let vehicle: Vehicle

    private struct Row: Identifiable {
        let id = UUID()
        let systemImage: String
        let label: String
        let value: String
    }

    private var rows: [Row] {
        [
            Row(systemImage: "tag.fill", label: "Marka", value: vehicle.make),
            Row(systemImage: "car.fill", label: "Model", value: vehicle.model),
            Row(systemImage: "calendar", label: "Yıl", value: vehicle.year.description),
            Row(systemImage: "gauge.with.dots.needle.67percent", label: "Kilometre", value: vehicle.mileageKm.formattedMileage()),
            Row(systemImage: "fuelpump.fill", label: "Yakıt Türü", value: vehicle.fuelType.displayName),
            Row(systemImage: "engine.combustion.fill", label: "Motor", value: vehicle.engine),
            Row(systemImage: "gearshape.2.fill", label: "Şanzıman", value: vehicle.transmission)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Teknik Özellikler")

                    CardView {
                        VStack(spacing: 0) {
                            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: row.systemImage)
                                        .font(.system(size: AppSizes.iconSmall))
                                        .foregroundStyle(AppTheme.primary)
                                        .frame(width: AppSizes.iconLarge)
                                        .accessibilityHidden(true)

                                    Text(row.label)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppTheme.textSecondary)

                                    Spacer()

                                    Text(row.value)
                                        .font(AppTypography.bodyEmphasized)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                .padding(.vertical, AppSpacing.sm)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(row.label): \(row.value)")

                                if index < rows.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient.graphiteSurface()

            Image(systemName: "car.side.fill")
                .font(.system(size: 108))
                .foregroundStyle(.white.opacity(0.08))
                .frame(width: 108, height: 108)
                .offset(x: 56, y: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
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

                    Text("Güncel kilometre")
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
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
