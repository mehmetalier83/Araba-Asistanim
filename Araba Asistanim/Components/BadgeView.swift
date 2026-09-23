import SwiftUI

/// A minimal numeric/dot indicator — e.g. an unread count. Distinct from TagView:
/// TagView labels a status with words, BadgeView marks a count or presence.
struct BadgeView: View {
    var count: Int? = nil

    var body: some View {
        Group {
            if let count {
                Text(count > 99 ? "99+" : "\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 18, minHeight: 18)
            } else {
                Color.clear.frame(width: 8, height: 8)
            }
        }
        .background(AppTheme.error)
        .clipShape(Capsule())
        .accessibilityLabel(count.map { "\($0) unread" } ?? "New")
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        BadgeView(count: 3)
        BadgeView(count: 120)
        BadgeView()
    }
    .padding()
}
