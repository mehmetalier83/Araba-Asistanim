import Foundation

/// Time filter for Analytics charts: how many months (ending with the
/// current one) each range covers.
enum AnalyticsTimeRange: String, CaseIterable, Identifiable {
    case oneMonth = "1A"
    case sixMonths = "6A"
    case oneYear = "1Y"
    case all = "Tümü"

    var id: String { rawValue }

    /// `history` is how many months of records exist; "Tümü" spans all of them.
    func monthCount(history: Int) -> Int {
        switch self {
        case .oneMonth: return 1
        case .sixMonths: return 6
        case .oneYear: return 12
        case .all: return max(history, 1)
        }
    }
}
