import SwiftUI

/// A one-time, swipeable walkthrough of the app's four pillars, shown before
/// the branded Welcome/sign-in screen on a person's very first launch only
/// (gated by `hasSeenOnboarding` in `AppRootView`). Each page reuses the same
/// "gradient circle + icon" illustration language already established by
/// `EmptyStateView`, just larger and with a different accent per page, so the
/// whole flow still reads as one consistent design system rather than a
/// bolted-on marketing carousel.
struct OnboardingView: View {
    let onFinished: () -> Void

    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "car.2.fill",
            tint: AppTheme.primary,
            title: "Tüm Araçların Tek Yerde",
            message: "Kaç araç olursa olsun — kilometre, yakıt türü ve teknik bilgileri tek dokunuşla yönet."
        ),
        OnboardingPage(
            icon: "doc.text.viewfinder",
            tint: AppTheme.categoryTeal,
            title: "Fişini Okut, Gerisini Bırak",
            message: "Fiş fotoğrafı çek; tutar, kategori ve işletme adı otomatik algılansın. Sen sadece kontrol et."
        ),
        OnboardingPage(
            icon: "chart.pie.fill",
            tint: AppTheme.success,
            title: "Harcamalarını Netleştir",
            message: "Yakıt, bakım ve diğer giderlerini kategoriye göre incele; aylık trendleri bir bakışta gör."
        ),
        OnboardingPage(
            icon: "sparkles",
            tint: AppTheme.categoryPurple,
            title: "Yapay Zeka Asistanın Yanında",
            message: "Araç geçmişin hakkında soru sor; tüketim, bakım zamanlaması ve giderlerle ilgili kişisel öneriler al."
        )
    ]

    private var isLastPage: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !isLastPage {
                    Button("Geç") {
                        HapticFeedback.success()
                        onFinished()
                    }
                    .font(AppTypography.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(height: AppSizes.minTouchTarget)
            .padding(.horizontal, AppSpacing.md)

            TabView(selection: $page.animation(reduceMotion ? nil : AppAnimation.standard)) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    pageContent(item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: AppSpacing.lg) {
                pageIndicator

                PrimaryButton(
                    title: isLastPage ? "Başlayalım" : "İleri",
                    icon: isLastPage ? "checkmark" : "arrow.right"
                ) {
                    advance()
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
        }
        .background(AppTheme.background)
    }

    private func pageContent(_ item: OnboardingPage) -> some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer(minLength: 0)

            illustration(for: item)

            VStack(spacing: AppSpacing.sm) {
                Text(item.title)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(item.message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.xl)

            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
    }

    private func illustration(for item: OnboardingPage) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [item.tint.opacity(0.22), item.tint.opacity(0.02)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 240, height: 240)

            Image(systemName: "sparkle")
                .font(.system(size: 16))
                .foregroundStyle(item.tint.opacity(0.5))
                .offset(x: -82, y: -64)

            Image(systemName: "sparkle")
                .font(.system(size: 11))
                .foregroundStyle(item.tint.opacity(0.4))
                .offset(x: 86, y: -30)

            Image(systemName: item.icon)
                .font(.system(size: 76, weight: .medium))
                .foregroundStyle(item.tint)
        }
        .accessibilityHidden(true)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AppTheme.primary : AppTheme.border)
                    .frame(width: index == page ? 20 : 6, height: 6)
                    .animation(reduceMotion ? nil : AppAnimation.fast, value: page)
            }
        }
        .accessibilityHidden(true)
    }

    private func advance() {
        if isLastPage {
            HapticFeedback.success()
            onFinished()
        } else {
            withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                page += 1
            }
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let tint: Color
    let title: String
    let message: String
}

#Preview {
    OnboardingView {}
}

#Preview("Dark") {
    OnboardingView {}
        .preferredColorScheme(.dark)
}
