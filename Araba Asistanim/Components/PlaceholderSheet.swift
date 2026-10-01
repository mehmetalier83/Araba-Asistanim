import SwiftUI

/// A generic "coming soon" sheet used to stand in for screens whose real
/// functionality (record creation, backend integration) isn't implemented yet.
/// Presented at a medium detent so it reads as a light, native confirmation
/// rather than a full navigational push.
struct PlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Spacer(minLength: 0)

                Image(systemName: systemImage)
                    .font(.system(size: AppSizes.iconLarge))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 88, height: 88)
                    .background(AppTheme.primarySubtle)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.title2)
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }

                Spacer(minLength: 0)

                PrimaryButton(title: "Anladım") {
                    dismiss()
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.vertical, AppSpacing.lg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            PlaceholderSheet(
                systemImage: "fuelpump.fill",
                title: "Yakıt Ekle",
                message: "Yakıt kaydı oluşturma özelliği henüz eklenmedi. Bu özellik ileride kullanılabilir olacak."
            )
        }
}
