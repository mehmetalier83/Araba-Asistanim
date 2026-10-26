import SwiftUI

/// One vehicle's specs and expense summary. Reads the vehicle live from
/// GarageStore by id, so mileage bumped by a new record shows up immediately.
/// `allowsDelete` is only set from the Vehicles tab (Home's shortcut push
/// leaves it off, so no delete affordance appears there).
struct VehicleDetailView: View {
    let vehicleID: UUID
    var allowsDelete = false

    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingAddExpense = false
    @State private var isShowingMileageEditor = false
    @State private var mileageDraft = ""

    var body: some View {
        if let vehicle = store.vehicle(withID: vehicleID) {
            content(for: vehicle)
        } else {
            EmptyStateView(
                systemImage: "car.fill",
                title: "Araç bulunamadı",
                message: "Bu araç silinmiş olabilir."
            )
        }
    }

    private struct Row: Identifiable {
        let id = UUID()
        let systemImage: String
        let label: String
        let value: String
    }

    private func rows(for vehicle: Vehicle) -> [Row] {
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

    private func content(for vehicle: Vehicle) -> some View {
        let rows = rows(for: vehicle)
        let insights = GarageInsights(store: store, vehicle: vehicle)

        return ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header(for: vehicle)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SectionHeader(title: "Teknik Özellikler")

                    CardView {
                        VStack(spacing: 0) {
                            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: row.systemImage)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppTheme.primary)
                                        .frame(width: 32, height: 32)
                                        .background(AppTheme.primarySubtle, in: Circle())
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

                expensesSection(for: vehicle, insights: insights)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .appScreenBackground()
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(vehicle: vehicle) { expense in
                withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                    store.addExpense(expense)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    mileageDraft = String(vehicle.mileageKm)
                    isShowingMileageEditor = true
                } label: {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                }
                .accessibilityLabel("Kilometreyi Güncelle")
            }
            if allowsDelete {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Aracı Sil")
                }
            }
        }
        .confirmationDialog(
            "\(vehicle.displayName) silinsin mi?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Aracı Sil", role: .destructive) {
                store.deleteVehicle(vehicle)
                HapticFeedback.success()
                dismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Araç ve ona ait tüm yakıt, bakım ve gider kayıtları silinir. Bu işlem geri alınamaz.")
        }
        .alert("Kilometreyi Güncelle", isPresented: $isShowingMileageEditor) {
            TextField("Güncel kilometre", text: $mileageDraft)
                .keyboardType(.numberPad)
            Button("Kaydet") {
                guard let value = Int(mileageDraft.filter(\.isNumber)), value >= 0 else { return }
                var updated = vehicle
                updated.mileageKm = value
                store.updateVehicle(updated)
                HapticFeedback.success()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Aracının göstergesindeki güncel kilometreyi gir.")
        }
    }

    // MARK: - Expenses

    private func expensesSection(for vehicle: Vehicle, insights: GarageInsights) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Giderler")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    isShowingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.primarySubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(.appPressScale)
                .accessibilityLabel("Gider Ekle")
            }

            NavigationLink {
                ExpensesListView(vehicle: vehicle)
            } label: {
                CardView {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Text("Bu Ay")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppTheme.textSecondary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                                .foregroundStyle(AppTheme.textTertiary)
                        }

                        Text(insights.thisMonthTotal.formattedCurrencyTL())
                            .font(AppTypography.valueEmphasis)
                            .foregroundStyle(AppTheme.textPrimary)

                        if let latest = insights.spending.first {
                            HStack(spacing: 6) {
                                Image(systemName: latest.category.systemImage)
                                    .font(.system(size: 11))
                                    .foregroundStyle(latest.category.tintColor)

                                Text("Son: \(latest.category.displayName) · \(latest.amount.formattedCurrencyTL())")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(1)
                            }
                        } else {
                            Text("Henüz gider eklenmedi")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                }
            }
            .buttonStyle(.appPressScale)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Giderler, bu ay \(insights.thisMonthTotal.formattedCurrencyTL())")
            .accessibilityHint("Tüm giderleri gör")
        }
    }

    private func header(for vehicle: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.displayName)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(vehicle.year.description) · \(vehicle.engine)")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.mileageKm.formattedMileage())
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Güncel kilometre")
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }

            HStack(spacing: AppSpacing.xs) {
                heroChip(vehicle.fuelType.displayName, systemImage: "fuelpump.fill")
                if !vehicle.transmission.isEmpty {
                    heroChip(vehicle.transmission, systemImage: "gearshape.fill")
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandHeroBackground())
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow(AppShadow.primaryGlow)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vehicle.displayName), \(vehicle.year.description), \(vehicle.mileageKm.formattedMileage())")
    }

    private func heroChip(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.18), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        VehicleDetailView(vehicleID: PreviewData.vehicles[0].id, allowsDelete: true)
    }
    .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    NavigationStack {
        VehicleDetailView(vehicleID: PreviewData.vehicles[0].id)
    }
    .environmentObject(GarageStore.preview)
    .preferredColorScheme(.dark)
}
