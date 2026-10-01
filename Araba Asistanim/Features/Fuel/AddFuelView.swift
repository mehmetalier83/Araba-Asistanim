import SwiftUI

/// The Add/Edit Fuel sheet — reachable from Home's "Yakıt Ekle" quick action.
/// Visually mirrors `AddExpenseView` (same section rhythm, same prominent
/// `AmountField`, same icon-led fields) so the two "Add" flows read as one
/// coherent system rather than two different form languages.
///
/// There is no backend yet, so saving just hands the built `FuelRecord` back
/// via `onSave` — the caller decides what to do with it (e.g. Home also logs
/// it as a `.fuel` expense so it shows up in "Son Hareketler" immediately).
struct AddFuelView: View {
    let vehicle: Vehicle
    var existingRecord: FuelRecord? = nil
    let onSave: (FuelRecord) -> Void

    @StateObject private var viewModel: AddFuelViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isShowingMoreDetails = false

    init(vehicle: Vehicle, existingRecord: FuelRecord? = nil, onSave: @escaping (FuelRecord) -> Void) {
        self.vehicle = vehicle
        self.existingRecord = existingRecord
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: AddFuelViewModel(vehicle: vehicle, existing: existingRecord))
    }

    private var isEditing: Bool { existingRecord != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(isEditing ? "Yakıtı düzenle" : "Yakıt ekle")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("\(vehicle.displayName) için yakıt bilgilerini gir.")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, AppSpacing.xs)

                    section(title: "Fiş Tara") {
                        ReceiptAttachmentView(imageData: $viewModel.receiptImageData) { result in
                            viewModel.applyScanResult(result)
                        }

                        if viewModel.didAutoFillFromReceipt {
                            AutoFillBanner(isPresented: $viewModel.didAutoFillFromReceipt)
                                .transition(.opacity)
                        }
                    }

                    section(title: "Yakıt Bilgisi") {
                        AppTextField(
                            title: "Litre",
                            placeholder: "42.5",
                            text: $viewModel.litersText,
                            icon: "fuelpump.fill",
                            keyboardType: .decimalPad,
                            errorMessage: viewModel.litersError
                        )
                        .onChange(of: viewModel.litersText) { viewModel.clearLitersError() }

                        fullTankToggle
                    }

                    section(title: "Ödeme") {
                        AmountField(text: $viewModel.costText, errorMessage: viewModel.costError)
                            .onChange(of: viewModel.costText) { viewModel.clearCostError() }

                        if let hint = viewModel.pricePerLiterText {
                            Text(hint)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .transition(.opacity)
                        }

                        dateField
                    }

                    ExpandableSection(title: "Daha Fazla Detay", isExpanded: $isShowingMoreDetails) {
                        AppTextField(
                            title: "Kilometre",
                            placeholder: "124580",
                            text: $viewModel.mileageText,
                            icon: "gauge.with.dots.needle.67percent",
                            keyboardType: .numberPad,
                            errorMessage: viewModel.mileageError
                        )
                        .onChange(of: viewModel.mileageText) { viewModel.clearMileageError() }

                        AppTextField(
                            title: "İstasyon",
                            placeholder: "Örn. Shell",
                            text: $viewModel.station,
                            icon: "fuelpump.circle.fill"
                        )
                    }

                    PrimaryButton(title: isEditing ? "Kaydet" : "Yakıtı Kaydet", icon: "checkmark") {
                        submit()
                    }
                }
                .padding(AppSpacing.md)
                .animation(reduceMotion ? nil : AppAnimation.fast, value: viewModel.pricePerLiterText)
                .animation(reduceMotion ? nil : AppAnimation.fast, value: viewModel.didAutoFillFromReceipt)
            }
            .background(AppTheme.background)
            .navigationTitle(isEditing ? "Yakıtı Düzenle" : "Yakıt Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppTheme.textPrimary)

            content()
        }
    }

    private var fullTankToggle: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: AppSizes.iconSmall))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: AppSizes.iconMedium)

            Text("Depo Doluya Kadar")
                .font(AppTypography.body)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer(minLength: 0)

            Toggle("", isOn: $viewModel.isFullTank)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(height: AppSizes.buttonHeight)
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var dateField: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Tarih")
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "calendar")
                    .font(.system(size: AppSizes.iconSmall))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: AppSizes.iconMedium)

                DatePicker("Tarih", selection: $viewModel.date, in: ...Date.now, displayedComponents: .date)
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "tr_TR"))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.sm)
            .frame(height: AppSizes.buttonHeight)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
        }
    }

    private func submit() {
        guard let record = viewModel.buildFuelRecord() else { return }
        onSave(record)
        HapticFeedback.success()
        dismiss()
    }
}

#Preview {
    AddFuelView(vehicle: PreviewData.vehicles[0]) { _ in }
}

#Preview("Dark") {
    AddFuelView(vehicle: PreviewData.vehicles[0]) { _ in }
        .preferredColorScheme(.dark)
}
