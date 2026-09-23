import Foundation

/// Formatters use a fixed POSIX locale so mock/demo values render consistently
/// (e.g. "120,450 km") regardless of the simulator or device's region settings.
private let groupedNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    formatter.decimalSeparator = "."
    formatter.usesGroupingSeparator = true
    formatter.maximumFractionDigits = 0
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension Int {
    /// Formats a mileage value, e.g. `120450` → `"120,450 km"`.
    func formattedMileage() -> String {
        let number = groupedNumberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(number) km"
    }
}

extension Double {
    /// Formats a monetary value, e.g. `7850` → `"7,850 TL"`.
    func formattedCurrencyTL() -> String {
        let number = groupedNumberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(number) TL"
    }

    /// Formats a per-kilometer cost with two decimal places, e.g. `0.68` → `"0.68 TL"`.
    func formattedCostPerKm() -> String {
        String(format: "%.2f TL", self)
    }

    /// Formats a fuel consumption value, e.g. `7.8` → `"7.8 L/100 km"`.
    func formattedFuelConsumption() -> String {
        String(format: "%.1f L/100 km", self)
    }
}
