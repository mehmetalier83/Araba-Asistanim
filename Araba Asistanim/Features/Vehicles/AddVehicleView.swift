import SwiftUI

/// A real "Add Vehicle" form. Make and model are searched and picked from a
/// live vehicle registry (see VehicleAPIServiceProtocol) instead of a small
/// hand-written list. Engine, transmission, year and mileage stay as manual
/// entry — no free API supplies trim-level specs or knows this specific car's
/// mileage.
///
/// There is no backend yet, so submitting appends the vehicle straight to
/// VehiclesViewModel's in-memory list via `onAdd` — it resets on next launch,
/// same as every other mock-phase data source in this app.
struct AddVehicleView: View {
    let onAdd: (Vehicle) -> Void

    @StateObject private var viewModel = AddVehicleViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isShowingMakeSheet = false
    @State private var isShowingModelSheet = false

    private let fuelColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Aracını ekle")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Marka ve modeli ara, geri kalan bilgileri gir.")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, AppSpacing.xs)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        makeField
                        modelField

                        fuelTypePicker

                        AppTextField(title: "Motor", placeholder: "2.0L Turbo I4", text: $viewModel.engine, icon: "engine.combustion.fill", errorMessage: viewModel.engineError)
                            .onChange(of: viewModel.engine) { viewModel.clearEngineError() }

                        AppTextField(title: "Şanzıman", placeholder: "8 İleri Otomatik", text: $viewModel.transmission, icon: "gearshape.2.fill", errorMessage: viewModel.transmissionError)
                            .onChange(of: viewModel.transmission) { viewModel.clearTransmissionError() }

                        HStack(spacing: AppSpacing.sm) {
                            AppTextField(title: "Yıl", placeholder: "2018", text: $viewModel.year, icon: "calendar", keyboardType: .numberPad, errorMessage: viewModel.yearError)
                                .onChange(of: viewModel.year) { viewModel.clearYearError() }

                            AppTextField(title: "Kilometre", placeholder: "120450", text: $viewModel.mileage, icon: "gauge.with.dots.needle.67percent", keyboardType: .numberPad, errorMessage: viewModel.mileageError)
                                .onChange(of: viewModel.mileage) { viewModel.clearMileageError() }
                        }
                    }

                    PrimaryButton(title: "Araç Ekle", icon: "arrow.right") {
                        submit()
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppTheme.background)
            .navigationTitle("Araç Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
            .task {
                await viewModel.loadMakes()
            }
        }
    }

    // MARK: - Make / model

    private var makeField: some View {
        Button {
            isShowingMakeSheet = true
        } label: {
            AppPickerField(
                title: "Marka",
                placeholder: viewModel.isLoadingMakes ? "Markalar yükleniyor…" : "Marka seç",
                selection: viewModel.selectedMake,
                icon: "magnifyingglass",
                isEnabled: !viewModel.isLoadingMakes,
                errorMessage: viewModel.makeValidationError
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoadingMakes)
        .sheet(isPresented: $isShowingMakeSheet) {
            SearchablePickerSheet(
                title: "Marka Seç",
                items: viewModel.makes,
                isLoading: viewModel.isLoadingMakes,
                errorMessage: viewModel.makesError,
                onSelect: { viewModel.selectMake($0) },
                onRetry: { Task { await viewModel.loadMakes() } }
            )
        }
    }

    private var modelField: some View {
        Button {
            isShowingModelSheet = true
        } label: {
            AppPickerField(
                title: "Model",
                placeholder: viewModel.selectedMake == nil ? "Önce marka seç" : (viewModel.isLoadingModels ? "Modeller yükleniyor…" : "Model seç"),
                selection: viewModel.selectedModel,
                isEnabled: viewModel.selectedMake != nil && !viewModel.isLoadingModels,
                errorMessage: viewModel.modelValidationError
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.selectedMake == nil || viewModel.isLoadingModels)
        .sheet(isPresented: $isShowingModelSheet) {
            SearchablePickerSheet(
                title: "Model Seç",
                items: viewModel.models,
                isLoading: viewModel.isLoadingModels,
                errorMessage: viewModel.modelsError,
                onSelect: { viewModel.selectModel($0) },
                onRetry: {
                    if let make = viewModel.selectedMake {
                        viewModel.selectMake(make)
                    }
                }
            )
        }
    }

    private var fuelTypePicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("Yakıt Türü")
                .font(AppTypography.footnote)
                .foregroundStyle(AppTheme.textSecondary)

            LazyVGrid(columns: fuelColumns, spacing: AppSpacing.xs) {
                ForEach(FuelType.allCases, id: \.self) { type in
                    let isSelected = viewModel.fuelType == type

                    Button {
                        withAnimation(reduceMotion ? nil : AppAnimation.fast) {
                            viewModel.fuelType = type
                        }
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: type.icon)
                                .font(.system(size: AppSizes.iconSmall))
                                .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)

                            Text(type.displayName)
                                .font(AppTypography.subheadline)
                                .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: AppSizes.minTouchTarget)
                        .background(isSelected ? AppTheme.primarySubtle : AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                                .stroke(isSelected ? AppTheme.primary : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.appPressScale)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    private func submit() {
        guard let vehicle = viewModel.buildVehicle() else { return }
        onAdd(vehicle)
        HapticFeedback.success()
        dismiss()
    }
}

#Preview {
    AddVehicleView { _ in }
}

#Preview("Dark") {
    AddVehicleView { _ in }
        .preferredColorScheme(.dark)
}
