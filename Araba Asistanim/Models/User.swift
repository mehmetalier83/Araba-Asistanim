import Foundation

/// The signed-in user's profile.
struct User: Identifiable, Hashable, Codable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}
