import Foundation

/// A single data point in a monthly time series, used to drive Analytics charts.
struct MonthlyValue: Identifiable, Hashable {
    var id: String { month }
    /// Chart label — unique within one series (a year suffix is added once a
    /// series spans more than 12 months).
    let month: String
    let value: Double
}
