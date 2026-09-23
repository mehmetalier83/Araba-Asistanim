import SwiftUI

struct SettingsView: View {
    private struct Row: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
    }

    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isShowingLogoutConfirmation = false

    private let preferenceRows = [
        Row(title: "Appearance", systemImage: "circle.lefthalf.filled"),
        Row(title: "Notifications", systemImage: "bell.fill"),
        Row(title: "Units", systemImage: "ruler.fill"),
        Row(title: "Currency", systemImage: "banknote.fill")
    ]

    private let aboutRows = [
        Row(title: "About CarLog AI", systemImage: "info.circle.fill"),
        Row(title: "Privacy Policy", systemImage: "hand.raised.fill"),
        Row(title: "Terms of Service", systemImage: "doc.text.fill")
    ]

    var body: some View {
        List {
            if let user = authViewModel.currentUser {
                Section("Account") {
                    accountHeader(for: user)
                    SettingsRowView(row: Row(title: "Email", systemImage: "envelope.fill"), value: user.email)
                }
            }

            Section("Preferences") {
                ForEach(preferenceRows) { row in
                    SettingsRowView(row: row)
                }
            }

            Section("About") {
                ForEach(aboutRows) { row in
                    SettingsRowView(row: row)
                }
            }

            Section {
                Button(role: .destructive) {
                    isShowingLogoutConfirmation = true
                } label: {
                    Text("Log Out")
                        .font(AppTypography.body)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you sure you want to log out?",
            isPresented: $isShowingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                authViewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func accountHeader(for user: User) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(user.initials)
                .font(AppTypography.headline)
                .foregroundStyle(.white)
                .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                .background(AppTheme.primary)
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text(user.fullName)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.vertical, AppSpacing.xxs)
        .accessibilityElement(children: .combine)
    }

    private struct SettingsRowView: View {
        let row: Row
        var value: String? = nil

        var body: some View {
            Label {
                HStack {
                    Text(row.title)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textPrimary)

                    if let value {
                        Spacer()
                        Text(value)
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            } icon: {
                Image(systemName: row.systemImage)
                    .foregroundStyle(AppTheme.primary)
            }
            .accessibilityLabel(value.map { "\(row.title): \($0)" } ?? row.title)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
}

#Preview("Dark") {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
    .preferredColorScheme(.dark)
}
