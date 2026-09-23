import SwiftUI

/// Groups the vehicle's key figures into one card with divided rows, instead of
/// a grid of equally-weighted statistic tiles. The "Next Service" row carries a
/// status tag when service is due soon or overdue, tying Home directly to the
/// same status model used on the Maintenance tab.
struct VehicleHealthCard: View {
    struct Row: Identifiable {
        let id = UUID()
        let systemImage: String
        let title: String
        let value: String
        var tag: (text: String, tone: TagView.Tone)? = nil
    }

    let rows: [Row]

    var body: some View {
        CardView {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: row.systemImage)
                            .font(.system(size: AppSizes.iconSmall))
                            .foregroundStyle(AppTheme.primary)
                            .frame(width: AppSizes.iconLarge)
                            .accessibilityHidden(true)

                        Text(row.title)
                            .font(AppTypography.body)
                            .foregroundStyle(AppTheme.textPrimary)

                        Spacer()

                        if let tag = row.tag {
                            TagView(text: tag.text, tone: tag.tone)
                        } else {
                            Text(row.value)
                                .font(AppTypography.valueEmphasis)
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .padding(.vertical, AppSpacing.sm)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(row.title): \(row.tag?.text ?? row.value)")

                    if index < rows.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
}

#Preview {
    VehicleHealthCard(rows: [
        .init(systemImage: "fuelpump.fill", title: "Fuel Consumption", value: "7.8 L/100 km"),
        .init(systemImage: "banknote.fill", title: "Monthly Expenses", value: "7,850 TL"),
        .init(systemImage: "wrench.and.screwdriver.fill", title: "Next Service", value: "", tag: ("Due Soon", .warning))
    ])
    .padding()
}
