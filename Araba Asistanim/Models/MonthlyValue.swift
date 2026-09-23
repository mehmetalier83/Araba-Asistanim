import Foundation

/// A single data point in a monthly time series, used to drive Analytics charts.
struct MonthlyValue: Identifiable, Hashable {
    var id: String { month }
    let month: String
    let value: Double
}
