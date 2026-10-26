import SwiftUI

/// The Home bell: every overdue or due-soon maintenance reminder across all
/// vehicles, derived from the service history (see `MaintenanceSchedule`).
struct NotificationsSheet: View {
    let reminders: [MaintenanceRecord]
    let onOpenMaintenance: () -> Void

    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    EmptyStateView(
                        systemImage: "bell.slash.fill",
                        title: "Bildirim yok",
                        message: "Yaklaşan ya da geciken bir bakım olduğunda burada göreceksin."
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.sm) {
                            ForEach(reminders) { reminder in
                                Button {
                                    store.selectedVehicleID = reminder.vehicleID
                                    dismiss()
                                    onOpenMaintenance()
                                } label: {
                                    row(for: reminder)
                                }
                                .buttonStyle(.appPressScale)
                                .foregroundStyle(AppTheme.textPrimary)
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .appScreenBackground()
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func row(for reminder: MaintenanceRecord) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: reminder.category.systemImage)
                .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                .foregroundStyle(reminder.status.tagTone.foreground)
                .frame(width: 42, height: 42)
                .background(reminder.status.tagTone.background, in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("\(store.vehicle(withID: reminder.vehicleID)?.displayName ?? "") · \(reminder.dueSummary)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            TagView(text: reminder.status.label, tone: reminder.status.tagTone)
        }
        .padding(AppSpacing.md)
        .appCard(cornerRadius: 18)
        .accessibilityElement(children: .combine)
    }
}
