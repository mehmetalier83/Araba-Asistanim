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
    @EnvironmentObject private var store: GarageStore
    @State private var isShowingLogoutConfirmation = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var deleteErrorMessage: String?
    @State private var activeRow: Row?
    @AppStorage(AppearancePreference.storageKey) private var appearance = AppearancePreference.system

    private let preferenceRows = [
        Row(title: "Dil", systemImage: "globe", value: "Türkçe", message: "Dil seçenekleri yakında eklenecek. Uygulama şu an Türkçe olarak sunuluyor."),
        Row(title: "Bildirimler", systemImage: "bell.fill", message: "Bildirim tercihleri henüz eklenmedi. Bu özellik ileride kullanılabilir olacak."),
        Row(title: "Birimler", systemImage: "ruler.fill", message: "Mesafe birimi tercihi henüz eklenmedi. Şu an kilometre kullanılıyor."),
        Row(title: "Para Birimi", systemImage: "banknote.fill", message: "Para birimi tercihi henüz eklenmedi. Şu an Türk Lirası kullanılıyor.")
    ]

    private let aboutRows = [
        Row(title: "\(AppBrand.name) Hakkında", systemImage: "info.circle.fill", message: "\(AppBrand.name), aracının bakım, yakıt ve giderlerini tek bir yerden takip etmeni sağlar."),
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
                appearancePicker
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

            Section {
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Text("Hesabı Sil")
                        }
                        Spacer()
                    }
                }
                .disabled(isDeletingAccount)
            } footer: {
                Text("Hesabın ve tüm araç, yakıt, bakım ve gider kayıtların kalıcı olarak silinir.")
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
        .confirmationDialog(
            "Hesabını silmek istediğine emin misin?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Hesabı Kalıcı Olarak Sil", role: .destructive) {
                Task { await deleteAccount() }
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
        .alert(
            "Hesap silinemedi",
            isPresented: Binding(get: { deleteErrorMessage != nil }, set: { if !$0 { deleteErrorMessage = nil } })
        ) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage ?? "")
        }
        .sheet(item: $activeRow) { row in
            PlaceholderSheet(systemImage: row.systemImage, title: row.title, message: row.message)
        }
    }

    private var appearancePicker: some View {
        Picker(selection: $appearance) {
            ForEach(AppearancePreference.allCases) { option in
                Text(option.title).tag(option)
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: AppSizes.iconXSmall))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: AppSizes.iconLarge, height: AppSizes.iconLarge)
                    .background(AppTheme.primarySubtle)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                    .accessibilityHidden(true)

                Text("Görünüm")
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .pickerStyle(.menu)
        .padding(.vertical, AppSpacing.xxs)
    }

    private func deleteAccount() async {
        isDeletingAccount = true
        defer { isDeletingAccount = false }
        do {
            // Records go first: deleting them needs the account to still exist.
            try await store.deleteAllData()
            try await authViewModel.deleteAccount()
            HapticFeedback.success()
        } catch {
            deleteErrorMessage = (error as? AuthError)?.errorDescription ?? AuthError.unknown.errorDescription
            HapticFeedback.error()
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
    .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AuthViewModel(repository: AuthRepository(
        service: MockAuthService(),
        secureStorage: InMemorySecureStorage()
    )))
    .environmentObject(GarageStore.preview)
    .preferredColorScheme(.dark)
}
