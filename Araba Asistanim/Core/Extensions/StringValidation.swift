import Foundation

extension String {
    /// A pragmatic email format check — good enough for client-side validation;
    /// the backend remains the source of truth for whether an address is real.
    var isValidEmail: Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}

extension String {
    /// Parses a user-typed decimal, accepting either "," (Turkish keyboards)
    /// or "." as the separator. `nil` if it isn't a number.
    var decimalValue: Double? {
        Double(trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: "."))
    }
}
