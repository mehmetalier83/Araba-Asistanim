import SwiftUI

/// A simple icon + title + message sheet (insight details, info rows in
/// Settings). Presented at a medium detent so it reads as a light, native confirmation
/// rather than a full navigational push.
struct PlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Scrolls so a long message (e.g. Home's insight detail)
                // is never truncated at the medium detent.
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
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
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.md)
                }
                .scrollBounceBehavior(.basedOnSize)

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
        .presentationDetents([.medium, .large])
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
