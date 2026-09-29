import SwiftUI

struct MaintenanceView: View {
    private let records = PreviewData.maintenanceRecords
    @State private var isShowingAddMaintenance = false

    private var overdue: [MaintenanceRecord] { records.filter { $0.status == .overdue } }
    private var dueSoon: [MaintenanceRecord] { records.filter { $0.status == .dueSoon } }
    private var completed: [MaintenanceRecord] { records.filter { $0.status == .completed } }

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    EmptyStateView(
                        systemImage: "wrench.and.screwdriver.fill",
                        title: "Henüz bakım kaydı yok",
                        message: "Araç geçmişini oluşturmak için servislerini takip et.",
                        actionTitle: "Bakım Ekle"
                    ) {
                        isShowingAddMaintenance = true
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            if !overdue.isEmpty {
                                section(title: "Gecikenler", records: overdue)
                            }
                            if !dueSoon.isEmpty {
                                section(title: "Yaklaşanlar", records: dueSoon)
                            }
                            if !completed.isEmpty {
                                section(title: "Geçmiş", records: completed)
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle("Bakım")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddMaintenance = true
                    } label: {
                        Label("Bakım Ekle", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddMaintenance) {
                PlaceholderSheet(
                    systemImage: "wrench.and.screwdriver.fill",
                    title: "Bakım Ekle",
                    message: "Bakım kaydı oluşturma özelliği henüz eklenmedi. Veri katmanı tamamlandığında kullanılabilir olacak."
                )
            }
        }
    }

    private func section(title: String, records: [MaintenanceRecord]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: title)

            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                        MaintenanceRecordRow(record: record)
                        if index < records.count - 1 {
                            Divider()
                                .padding(.leading, AppSizes.iconLarge + AppSpacing.sm)
                        }
                    }
                }
            }
        }
    }
}

/// A single row in a maintenance section: status dot, title, date, mileage, and
/// (for completed records) cost. Status communicates via both color and a text
/// tag, never color alone.
private struct MaintenanceRecordRow: View {
    let record: MaintenanceRecord

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: record.category.systemImage)
                .font(.system(size: AppSizes.iconSmall))
                .foregroundStyle(record.status.tagTone.foreground)
                .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                .background(record.status.tagTone.background)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("\(record.date.formattedDayMonthYear()) · \(record.mileageKm.formattedMileage())")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if let cost = record.cost {
                Text(cost.formattedCurrencyTL())
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)
            } else {
                TagView(text: record.status.label, tone: record.status.tagTone)
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(record.title), \(record.date.formattedDayMonthYear()), \(record.mileageKm.formattedMileage()), "
            + (record.cost.map { $0.formattedCurrencyTL() } ?? record.status.label)
        )
    }
}

#Preview {
    MaintenanceView()
}

#Preview("Dark") {
    MaintenanceView()
        .preferredColorScheme(.dark)
}
