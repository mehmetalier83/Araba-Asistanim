import Foundation

private let dayMonthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.locale = Locale(identifier: "tr_TR")
    return formatter
}()

private let dayMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM"
    formatter.locale = Locale(identifier: "tr_TR")
    return formatter
}()

extension Date {
    /// Formats a date as `"12 Ağustos 2026"`.
    func formattedDayMonthYear() -> String {
        dayMonthYearFormatter.string(from: self)
    }

    /// Formats a date as an uppercase section-header label, e.g. `"BUGÜN"`,
    /// `"DÜN"`, or `"22 EYLÜL"` for anything older.
    func formattedListSectionHeader() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "BUGÜN" }
        if calendar.isDateInYesterday(self) { return "DÜN" }
        return dayMonthFormatter.string(from: self).uppercased(with: Locale(identifier: "tr_TR"))
    }
}
