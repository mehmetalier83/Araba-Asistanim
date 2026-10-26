import SwiftUI

struct MaintenanceView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var isShowingAddMaintenance = false
    @State private var isShowingNoVehicleAlert = false
    @State private var editingRecord: MaintenanceRecord?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Shows the vehicle picked in VehicleSwitcherMenu (shared with Home/Analiz).
    private var vehicle: Vehicle? { store.selectedVehicle }

    private var reminders: [MaintenanceRecord] { vehicle.map { store.reminders(for: $0.id) } ?? [] }
    private var overdue: [MaintenanceRecord] { reminders.filter { $0.status == .overdue } }
    private var dueSoon: [MaintenanceRecord] { reminders.filter { $0.status == .dueSoon } }
    private var upcoming: [MaintenanceRecord] { reminders.filter { $0.status == .upcoming } }
    private var completed: [MaintenanceRecord] { vehicle.map { store.completedMaintenance(for: $0.id) } ?? [] }
    private var isEmpty: Bool { reminders.isEmpty && completed.isEmpty }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    EmptyStateView(
                        systemImage: "wrench.and.screwdriver.fill",
                        title: "Henüz bakım kaydı yok",
                        message: "Araç geçmişini oluşturmak için servislerini takip et.",
                        actionTitle: "Bakım Ekle"
                    ) {
                        addMaintenanceTapped()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            if let vehicle {
                                summaryCard(for: vehicle)
                            }

                            if !overdue.isEmpty {
                                section(title: "Gecikenler", records: overdue)
                            }
                            if !dueSoon.isEmpty {
                                section(title: "Yaklaşanlar", records: dueSoon)
                            }
                            if !upcoming.isEmpty {
                                section(title: "Planlı", records: upcoming)
                            }
                            if !completed.isEmpty {
                                section(title: "Geçmiş", records: completed)
                            }

                            Text("Planlı bakımlar, son yapılan bakım ve tipik servis aralıklarına (ör. yağ değişimi 10.000 km / 12 ay) göre hesaplanır. Basılı tutarak geçmiş kayıtları düzenleyebilir veya silebilirsin.")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .appScreenBackground()
            .navigationTitle("Bakım")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VehicleSwitcherMenu()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addMaintenanceTapped()
                    } label: {
                        Label("Bakım Ekle", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddMaintenance) {
                if let vehicle {
                    AddMaintenanceView(vehicle: vehicle) { record in
                        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                            store.addMaintenance(record)
                        }
                    }
                }
            }
            .sheet(item: $editingRecord) { record in
                if let vehicle {
                    AddMaintenanceView(vehicle: vehicle, existingRecord: record) { store.updateMaintenance($0) }
                }
            }
            .alert("Önce Araç Ekle", isPresented: $isShowingNoVehicleAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Bakım kaydı ekleyebilmek için önce Araçlar sekmesinden bir araç eklemelisin.")
            }
        }
    }

    private func addMaintenanceTapped() {
        if vehicle != nil {
            isShowingAddMaintenance = true
        } else {
            isShowingNoVehicleAlert = true
        }
    }

    // MARK: - Summary

    /// The vehicle's maintenance at a glance on the brand gradient: the score
    /// (from `GarageInsights`), the next item and how many are open.
    private func summaryCard(for vehicle: Vehicle) -> some View {
        let insights = GarageInsights(store: store, vehicle: vehicle)
        let next = insights.nextReminder

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bakım Durumu")
                        .font(AppTypography.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(insights.maintenanceScore.map { "%\($0)" } ?? "—")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.2), in: Circle())
                    .accessibilityHidden(true)
            }

            if let next {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: next.category.systemImage)
                    Text("Sıradaki: \(next.title) · \(next.dueSummary)")
                        .lineLimit(2)
                }
                .font(AppTypography.subheadline)
                .foregroundStyle(.white)
            }

            HStack(spacing: AppSpacing.xs) {
                countChip("Geciken", overdue.count)
                countChip("Yaklaşan", dueSoon.count)
                countChip("Planlı", upcoming.count)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandHeroBackground(showsCarGlyph: false))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.hero, style: .continuous))
        .appShadow(AppShadow.primaryGlow)
        .accessibilityElement(children: .combine)
    }

    private func countChip(_ title: String, _ count: Int) -> some View {
        HStack(spacing: 6) {
            Text("\(count)")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
            Text(title)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 6)
        .background(.white.opacity(count > 0 ? 0.22 : 0.12), in: Capsule())
    }

    // MARK: - Sections

    private func section(title: String, records: [MaintenanceRecord]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                        MaintenanceRecordRow(record: record)
                            .contextMenu {
                                if record.status == .completed {
                                    Button {
                                        editingRecord = record
                                    } label: {
                                        Label("Düzenle", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                                            store.deleteMaintenance(record)
                                        }
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                } else {
                                    Button {
                                        isShowingAddMaintenance = true
                                    } label: {
                                        Label("Yapıldı olarak kaydet", systemImage: "checkmark.circle")
                                    }
                                }
                            }
                        if index < records.count - 1 {
                            Divider()
                                .padding(.leading, 40 + AppSpacing.sm)
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
        HStack(alignment: .center, spacing: AppSpacing.sm) {
            Image(systemName: record.category.systemImage)
                .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                .foregroundStyle(record.status.tagTone.foreground)
                .frame(width: 40, height: 40)
                .background(record.status.tagTone.background, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(record.dueSummary)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if let cost = record.cost {
                Text(cost.formattedCurrencyTL())
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            } else {
                TagView(text: record.status.label, tone: record.status.tagTone)
            }
        }
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(record.title), \(record.dueSummary), "
            + (record.cost.map { $0.formattedCurrencyTL() } ?? record.status.label)
        )
    }
}

#Preview {
    MaintenanceView()
        .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    MaintenanceView()
        .environmentObject(GarageStore.preview)
        .preferredColorScheme(.dark)
}
