import Foundation

/// Time filter for Analytics charts. Mock data only spans 6 months, so "1Y" and
/// "All" both show the full range for now — the filter is still fully wired up
/// so it behaves correctly once real, longer-running data exists.
enum AnalyticsTimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1A"
    case sixMonths = "6A"
    case oneYear = "1Y"
    case all = "Tümü"

    var id: String { rawValue }

    func filter(_ values: [MonthlyValue]) -> [MonthlyValue] {
        switch self {
        case .oneMonth: return Array(values.suffix(1))
        case .sixMonths: return Array(values.suffix(6))
        case .oneYear, .all: return values
        }
    }
}
