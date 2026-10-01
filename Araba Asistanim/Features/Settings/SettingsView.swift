import SwiftUI

struct SettingsView: View {
    private struct Row: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        var value: String? = nil
        var message: String
    }

    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isShowingLogoutConfirmation = false
    @State private var activeRow: Row?

    private let preferenceRows = [
        Row(title: "Dil", systemImage: "globe", value: "Türkçe", message: "Dil seçenekleri yakında eklenecek. Uygulama şu an Türkçe olarak sunuluyor."),
        Row(title: "Görünüm", systemImage: "circle.lefthalf.filled", message: "Açık/koyu tema tercihi yakında eklenecek. Şu an sistem ayarını takip ediyor."),
        Row(title: "Bildirimler", systemImage: "bell.fill", message: "Bildirim tercihleri henüz eklenmedi. Bu özellik ileride kullanılabilir olacak."),
        Row(title: "Birimler", systemImage: "ruler.fill", message: "Mesafe birimi tercihi henüz eklenmedi. Şu an kilometre kullanılıyor."),
        Row(title: "Para Birimi", systemImage: "banknote.fill", message: "Para birimi tercihi henüz eklenmedi. Şu an Türk Lirası kullanılıyor.")
    ]

    private let aboutRows = [
        Row(title: "CarLog AI Hakkında", systemImage: "info.circle.fill", message: "CarLog AI, aracının bakım, yakıt ve giderlerini tek bir yerden takip etmeni sağlar."),
        Row(title: "Gizlilik Politikası", systemImage: "hand.raised.fill", message: "Gizlilik politikası metni henüz eklenmedi."),
        Row(title: "Kullanım Koşulları", systemImage: "doc.text.fill", message: "Kullanım koşulları metni henüz eklenmedi.")
    ]

    var body: some View {
        List {
            if let user = authViewModel.currentUser {
                Section("Hesap") {
                    accountHeader(for: user)
                    SettingsRowView(row: Row(title: "E-posta", systemImage: "envelope.fill", value: user.email, message: ""), isInformational: true, action: nil)
                }
            }

            Section("Tercihler") {
                ForEach(preferenceRows) { row in
                    SettingsRowView(row: row) { activeRow = row }
                }
            }

            Section("Hakkında") {
                ForEach(aboutRows) { row in
                    SettingsRowView(row: row) { activeRow = row }
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
        .sheet(item: $activeRow) { row in
            PlaceholderSheet(systemImage: row.systemImage, title: row.title, message: row.message)
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
        var isInformational: Bool = false
        var action: (() -> Void)?

        var body: some View {
            Group {
                if let action {
                    Button(action: action) { content }
                        .foregroundStyle(AppTheme.textPrimary)
                } else {
                    content
                }
            }
        }

        private var content: some View {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: row.systemImage)
                    .font(.system(size: AppSizes.iconXSmall))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                    .background(AppTheme.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                    .accessibilityHidden(true)

                Text(row.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                if let value = row.value {
                    Text(value)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if !isInformational {
                    Image(systemName: "chevron.right")
                        .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
            .padding(.vertical, AppSpacing.xxs)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(row.value.map { "\(row.title): \($0)" } ?? row.title)
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
