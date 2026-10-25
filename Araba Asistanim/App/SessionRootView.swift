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
        .alert(
            "Bir sorun oluştu",
            isPresented: Binding(
                get: { store.syncErrorMessage != nil },
                set: { if !$0 { store.syncErrorMessage = nil } }
            )
        ) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(store.syncErrorMessage ?? "")
        }
    }
}
