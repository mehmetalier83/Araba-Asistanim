import SwiftUI

/// A single expense's full detail — amount, category, date, mileage,
/// service, description, and receipt photo if attached — with edit and
/// delete actions. Reads the entry by id from GarageStore's ledger rather
/// than holding its own copy, so an edit made here is immediately reflected
/// if the user navigates back to the list.
struct ExpenseDetailView: View {
    let vehicle: Vehicle
    let expenseID: UUID

    @EnvironmentObject private var store: GarageStore

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingEdit = false
    @State private var isShowingDeleteConfirmation = false

    private var expense: ExpenseRecord? {
        store.spending(for: vehicle.id).first { $0.id == expenseID }
    }

    private struct Row: Identifiable {
        let id = UUID()
        let systemImage: String
        let label: String
        let value: String
    }

    private func rows(for expense: ExpenseRecord) -> [Row] {
        var rows = [
            Row(systemImage: "calendar", label: "Tarih", value: expense.date.formattedDayMonthYear())
        ]
        if let mileage = expense.mileageKm {
            rows.append(Row(systemImage: "gauge.with.dots.needle.67percent", label: "Kilometre", value: mileage.formattedMileage()))
        }
        if let serviceName = expense.serviceName, !serviceName.isEmpty {
            rows.append(Row(systemImage: "building.2.fill", label: "Servis / İşletme", value: serviceName))
        }
        return rows
    }

    var body: some View {
        Group {
            if let expense {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        header(expense)

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            SectionHeader(title: "Detaylar")

                            CardView {
                                VStack(spacing: 0) {
                                    let infoRows = rows(for: expense)
                                    ForEach(Array(infoRows.enumerated()), id: \.element.id) { index, row in
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
                                                .multilineTextAlignment(.trailing)
                                        }
                                        .padding(.vertical, AppSpacing.sm)
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("\(row.label): \(row.value)")

                                        if index < infoRows.count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }

                        if let note = expense.note, !note.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                SectionHeader(title: "Açıklama")
                                CardView {
                                    Text(note)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                            }
                        }

                        if let data = expense.receiptImageData, let uiImage = UIImage(data: data) {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                SectionHeader(title: "Fiş / Fatura")
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
                .appScreenBackground()
                .navigationTitle(expense.category.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: AppSpacing.lg) {
                            Button {
                                isShowingEdit = true
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .accessibilityLabel("Gideri Düzenle")

                            Button(role: .destructive) {
                                isShowingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .accessibilityLabel("Gideri Sil")
                        }
                    }
                }
                .sheet(isPresented: $isShowingEdit) {
                    LedgerEditSheet(vehicle: vehicle, expense: expense)
                }
                .confirmationDialog(
                    "Bu gider silinsin mi?",
                    isPresented: $isShowingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Gideri Sil", role: .destructive) {
                        store.deleteSpending(expense)
                        HapticFeedback.success()
                        dismiss()
                    }
                    Button("Vazgeç", role: .cancel) {}
                } message: {
                    Text("Bu işlem geri alınamaz.")
                }
            }
        }
    }

    private func header(_ expense: ExpenseRecord) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(systemName: expense.category.systemImage)
                .font(.system(size: AppSizes.iconMedium))
                .foregroundStyle(expense.category.tintColor)
                .frame(width: 64, height: 64)
                .background(expense.category.tintColor.opacity(0.12))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category.displayName)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                Text(expense.amount.formattedCurrencyTL())
                    .font(AppTypography.heroValue)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .padding(.top, AppSpacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.category.displayName), \(expense.amount.formattedCurrencyTL())")
    }
}

#Preview {
    NavigationStack {
        ExpenseDetailView(
            vehicle: PreviewData.vehicles[0],
            expenseID: PreviewData.allExpenses[3].id
        )
    }
    .environmentObject(GarageStore.preview)
}
