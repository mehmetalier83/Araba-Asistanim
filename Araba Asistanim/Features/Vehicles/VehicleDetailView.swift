import SwiftUI

/// A temporary vehicle detail screen. All fields are mock data in this phase.
/// `onDelete` is only supplied when reached from the Vehicles tab (where the
/// owning list can actually remove it) — Home's shortcut push leaves it nil,
/// so no delete affordance appears there.
struct VehicleDetailView: View {
    let vehicle: Vehicle
    var onDelete: (() -> Void)? = nil

    @StateObject private var expensesViewModel: ExpensesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingAddExpense = false

    init(vehicle: Vehicle, onDelete: (() -> Void)? = nil) {
        self.vehicle = vehicle
        self.onDelete = onDelete
        _expensesViewModel = StateObject(wrappedValue: ExpensesViewModel(vehicle: vehicle))
    }

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

                expensesSection
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppTheme.groupedBackground)
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddExpense) {
            AddExpenseView(vehicle: vehicle) { expense in
                withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                    expensesViewModel.addExpense(expense)
                }
            }
        }
        .toolbar {
            if onDelete != nil {
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
                onDelete?()
                HapticFeedback.success()
                dismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }

    // MARK: - Expenses

    private var expensesSection: some View {
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
                ExpensesListView(vehicle: vehicle, viewModel: expensesViewModel)
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

                        Text(expensesViewModel.thisMonthTotal.formattedCurrencyTL())
                            .font(AppTypography.valueEmphasis)
                            .foregroundStyle(AppTheme.textPrimary)

                        if let latest = expensesViewModel.latestExpense {
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
            .accessibilityLabel("Giderler, bu ay \(expensesViewModel.thisMonthTotal.formattedCurrencyTL())")
            .accessibilityHint("Tüm giderleri gör")
        }
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
