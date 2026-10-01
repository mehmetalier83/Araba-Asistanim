import SwiftUI

/// The Add/Edit Expense sheet — reachable from Vehicle Detail's Expenses
/// section, the Expenses list's toolbar, and Home's "Gider Ekle" quick
/// action. The same view drives both flows: passing `existingExpense`
/// pre-fills every field and switches the copy to an editing voice.
///
/// Kept deliberately minimal: only category, amount and date are visible by
/// default — mileage, service name and a note live behind "Daha Fazla
/// Detay" so logging a routine expense takes a few taps, not a full form.
///
/// There is no backend yet, so saving just hands the built `ExpenseRecord`
/// back via `onSave` — the caller's `ExpensesViewModel` appends or replaces
/// it in-memory, same as every other mock-phase data source in this app.
struct AddExpenseView: View {
    let vehicle: Vehicle
    var existingExpense: ExpenseRecord? = nil
    let onSave: (ExpenseRecord) -> Void

    @StateObject private var viewModel: AddExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isShowingMoreDetails = false

    private let categoryColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    init(vehicle: Vehicle, existingExpense: ExpenseRecord? = nil, onSave: @escaping (ExpenseRecord) -> Void) {
        self.vehicle = vehicle
        self.existingExpense = existingExpense
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: AddExpenseViewModel(vehicle: vehicle, existing: existingExpense))
    }

    private var isEditing: Bool { existingExpense != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(isEditing ? "Gideri düzenle" : "Yeni gider")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("\(vehicle.displayName) için gider bilgilerini gir.")
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

                    section(title: "Gider Türü") {
                        categoryGrid
                    }

                    section(title: "Ödeme") {
                        AmountField(text: $viewModel.amountText, errorMessage: viewModel.amountError)
                            .onChange(of: viewModel.amountText) { viewModel.clearAmountError() }

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
                            title: "Servis / İşletme",
                            placeholder: "Örn. ABC Oto Servis",
                            text: $viewModel.serviceName,
                            icon: "building.2.fill"
                        )

                        AppTextField(
                            title: "Açıklama",
                            placeholder: "Örn. 10.000 km periyodik bakım",
                            text: $viewModel.note,
                            icon: "text.alignleft"
                        )
                    }

                    PrimaryButton(title: isEditing ? "Kaydet" : "Gideri Kaydet", icon: "checkmark") {
                        submit()
                    }
                }
                .padding(AppSpacing.md)
                .animation(reduceMotion ? nil : AppAnimation.fast, value: viewModel.didAutoFillFromReceipt)
            }
            .background(AppTheme.background)
            .navigationTitle(isEditing ? "Gideri Düzenle" : "Gider Ekle")
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

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            LazyVGrid(columns: categoryColumns, spacing: AppSpacing.xs) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    categoryChip(category)
                }
            }

            if let error = viewModel.categoryError {
                ErrorView(message: error)
            }
        }
    }

    private func categoryChip(_ category: ExpenseCategory) -> some View {
        let isSelected = viewModel.category == category

        return Button {
            withAnimation(reduceMotion ? nil : AppAnimation.fast) {
                viewModel.category = category
            }
            viewModel.clearCategoryError()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: category.systemImage)
                    .font(.system(size: AppSizes.iconMedium * 0.8))
                    .foregroundStyle(isSelected ? .white : category.tintColor)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? category.tintColor : category.tintColor.opacity(0.12))
                    .clipShape(Circle())

                Text(category.displayName)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.xs)
            .background(isSelected ? category.tintColor.opacity(0.10) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(isSelected ? category.tintColor : AppTheme.border, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.appPressScale)
        .accessibilityLabel(category.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
        guard let expense = viewModel.buildExpense() else { return }
        onSave(expense)
        HapticFeedback.success()
        dismiss()
    }
}

#Preview {
    AddExpenseView(vehicle: PreviewData.vehicles[0]) { _ in }
}

#Preview("Dark") {
    AddExpenseView(vehicle: PreviewData.vehicles[0]) { _ in }
        .preferredColorScheme(.dark)
}

#Preview("Editing") {
    AddExpenseView(vehicle: PreviewData.vehicles[0], existingExpense: PreviewData.allExpenses[0]) { _ in }
}
