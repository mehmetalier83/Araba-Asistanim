import Foundation

private let dayMonthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension Date {
    /// Formats a date as `"12 August 2026"`.
    func formattedDayMonthYear() -> String {
        dayMonthYearFormatter.string(from: self)
    }
}
