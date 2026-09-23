import Foundation

extension String {
    /// A pragmatic email format check — good enough for client-side validation;
    /// the backend remains the source of truth for whether an address is real.
    var isValidEmail: Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}
