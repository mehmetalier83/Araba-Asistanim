import SwiftUI

/// A small pill showing period-over-period change, e.g. "↓12%". For metrics
/// where less is better (cost, consumption), a decrease reads as positive
/// (green) and an increase as attention-worthy (amber) — never red, since a
/// month-over-month uptick isn't an error state the way an overdue service is.
struct TrendBadge: View {
    let percent: Double

    private var isImprovement: Bool { percent <= 0 }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: isImprovement ? "arrow.down" : "arrow.up")
                .font(.system(size: 10, weight: .bold))
            Text("\(abs(Int(percent)))%")
                .font(AppTypography.captionEmphasized)
        }
        .foregroundStyle(isImprovement ? AppTheme.success : AppTheme.warning)
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 3)
        .background(isImprovement ? AppTheme.successSubtle : AppTheme.warningSubtle)
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isImprovement
                ? "Geçen aya göre yüzde \(abs(Int(percent))) düştü"
                : "Geçen aya göre yüzde \(abs(Int(percent))) arttı"
        )
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        TrendBadge(percent: -12)
        TrendBadge(percent: 8)
    }
    .padding()
}
