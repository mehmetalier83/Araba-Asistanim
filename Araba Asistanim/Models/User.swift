import Foundation

/// The signed-in user's profile. `id` is a String so it can hold a Firebase
/// Auth UID as-is (the mock backend uses UUID strings).
struct User: Identifiable, Hashable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    /// Turns "ayse.yilmaz@example.com" into ("Ayse", "Yilmaz") — a reasonable
    /// placeholder display name derived purely from the email, since
    /// registration doesn't ask for one.
    static func displayName(fromEmail email: String) -> (first: String, last: String) {
        let localPart = email.split(separator: "@").first.map(String.init) ?? email
        let parts = localPart
            .split(whereSeparator: { ".-_+".contains($0) })
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }

        guard let first = parts.first, !first.isEmpty else {
            return ("Kullanıcı", "")
        }
        let last = parts.dropFirst().joined(separator: " ")
        return (first, last)
    }
}
