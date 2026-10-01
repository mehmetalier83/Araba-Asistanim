import SwiftUI

/// A collapsible "more details" row — keeps a form's default view down to the
/// essentials (type, amount, date) while still letting secondary fields
/// (mileage, service name, notes) be filled in without a second screen.
/// Collapsed by default; already-filled fields stay wherever the caller put
/// them, this only controls visibility of the section's own content.
struct ExpandableSection<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Button {
                withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: AppSizes.iconSmall))
                        .foregroundStyle(AppTheme.primary)

                    Text(title)
                        .font(AppTypography.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.primary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: AppSizes.iconXSmall, weight: .semibold))
                        .foregroundStyle(AppTheme.primary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    content
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
