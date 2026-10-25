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
            .background(AppTheme.groupedBackground)
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

    private func section(title: String, records: [MaintenanceRecord]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: title)

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

                Text(record.dueSummary)
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
