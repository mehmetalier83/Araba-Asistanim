//
//  Araba_AsistanimApp.swift
//  Araba Asistanim
//
//  Created by Mehmet Ali on 23.09.2026.
//

import SwiftUI

@main
struct Araba_AsistanimApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel: AuthViewModel
    @AppStorage(AppearancePreference.storageKey) private var appearance = AppearancePreference.system

    init() {
        // Firebase Auth is used once GoogleService-Info.plist is in the app
        // bundle; until then MockAuthService keeps the app fully usable.
        let service: AuthServiceProtocol = FirebaseBootstrap.configureIfAvailable()
            ? FirebaseAuthService()
            : MockAuthService()
        let repository = AuthRepository(
            service: service,
            secureStorage: KeychainService()
        )
        _authViewModel = StateObject(wrappedValue: AuthViewModel(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}
