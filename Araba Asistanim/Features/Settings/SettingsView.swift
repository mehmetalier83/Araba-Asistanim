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
        Row(title: "Görünüm", systemImage: "circle.lefthalf.filled"),
        Row(title: "Bildirimler", systemImage: "bell.fill"),
        Row(title: "Birimler", systemImage: "ruler.fill"),
        Row(title: "Para Birimi", systemImage: "banknote.fill")
    ]

    private let aboutRows = [
        Row(title: "CarLog AI Hakkında", systemImage: "info.circle.fill"),
        Row(title: "Gizlilik Politikası", systemImage: "hand.raised.fill"),
        Row(title: "Kullanım Koşulları", systemImage: "doc.text.fill")
    ]

    var body: some View {
        List {
            if let user = authViewModel.currentUser {
                Section("Hesap") {
                    accountHeader(for: user)
                    SettingsRowView(row: Row(title: "E-posta", systemImage: "envelope.fill"), value: user.email)
                }
            }

            Section("Tercihler") {
                SettingsRowView(row: Row(title: "Dil", systemImage: "globe"), value: "Türkçe")
                ForEach(preferenceRows) { row in
                    SettingsRowView(row: row)
                }
            }

            Section("Hakkında") {
                ForEach(aboutRows) { row in
                    SettingsRowView(row: row)
                }
            }

            Section {
                Button(role: .destructive) {
                    isShowingLogoutConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Çıkış Yap")
                            .font(AppTypography.bodyEmphasized)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Çıkış yapmak istediğine emin misin?",
            isPresented: $isShowingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Çıkış Yap", role: .destructive) {
                authViewModel.signOut()
            }
            Button("Vazgeç", role: .cancel) {}
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
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: row.systemImage)
                    .font(.system(size: AppSizes.iconXSmall))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 28, height: 28)
                    .background(AppTheme.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                    .accessibilityHidden(true)

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
            .padding(.vertical, AppSpacing.xxs)
            .accessibilityElement(children: .combine)
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
