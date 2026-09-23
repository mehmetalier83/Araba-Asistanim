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

    init() {
        // MockAuthService stands in for the real ASP.NET backend until it
        // exists — swapping it out later means changing this one line.
        let repository = AuthRepository(
            service: MockAuthService(),
            secureStorage: KeychainService()
        )
        _authViewModel = StateObject(wrappedValue: AuthViewModel(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
        }
    }
}
