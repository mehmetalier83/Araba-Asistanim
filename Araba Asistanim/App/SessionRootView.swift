import SwiftUI

/// Owns the signed-in user's GarageStore for exactly as long as that user's
/// session lasts. `AppRootView` gives it `.id(user.id)`, so signing out (or
/// switching accounts) discards the store and nothing leaks between users.
struct SessionRootView: View {
    @StateObject private var store: GarageStore

    init(user: User) {
        _store = StateObject(wrappedValue: GarageStore(
            userID: user.id,
            repository: FirebaseBootstrap.isConfigured
                ? FirestoreGarageRepository(userID: user.id)
                : LocalGarageRepository(userID: user.id),
            seedsDemoData: AppSession.isDemoAccount
        ))
    }

    private var upcomingReminders: [(record: MaintenanceRecord, vehicleName: String)] {
        store.vehicles.flatMap { vehicle in
            store.reminders(for: vehicle.id).map { (record: $0, vehicleName: vehicle.displayName) }
        }
    }

    /// Changes whenever a reminder's title or date does, so notifications are rescheduled.
    private var reminderSchedule: [String] {
        upcomingReminders.map { "\($0.vehicleName)|\($0.record.title)|\($0.record.date.timeIntervalSince1970)" }
    }

    var body: some View {
        Group {
            if store.isLoaded {
                MainTabView()
            } else {
                LoadingView()
            }
        }
        .environmentObject(store)
        .task { await store.load() }
        .task(id: reminderSchedule) {
            guard store.isLoaded else { return }
            await MaintenanceNotificationScheduler.reschedule(upcomingReminders)
        }
        .alert(
            "Bir sorun oluştu",
            isPresented: Binding(
                get: { store.syncErrorMessage != nil },
                // Cleared by the button below instead of here: this setter
                // runs during the view update, where publishing is not allowed.
                set: { _ in }
            )
        ) {
            Button("Tamam", role: .cancel) { store.syncErrorMessage = nil }
        } message: {
            Text(store.syncErrorMessage ?? "")
        }
    }
}
