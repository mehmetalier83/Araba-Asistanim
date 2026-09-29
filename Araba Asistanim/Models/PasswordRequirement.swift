import Foundation

/// Password rules shown as a progressive checklist on Register, and enforced
/// defensively by MockAuthService — kept in one place so the UI and the
/// "backend" never disagree about what counts as a valid password.
enum PasswordRequirement: CaseIterable, Identifiable {
    case minLength
    case uppercase
    case number

    var id: Self { self }

    var description: String {
        switch self {
        case .minLength: return "En az 8 karakter"
        case .uppercase: return "Bir büyük harf"
        case .number: return "Bir rakam"
        }
    }

    func isSatisfied(by password: String) -> Bool {
        switch self {
        case .minLength: return password.count >= 8
        case .uppercase: return password.contains { $0.isUppercase }
        case .number: return password.contains { $0.isNumber }
        }
    }

    static func allSatisfied(by password: String) -> Bool {
        allCases.allSatisfy { $0.isSatisfied(by: password) }
    }
}
