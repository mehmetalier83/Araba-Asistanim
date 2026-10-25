import Foundation

/// What the person told onboarding before signing up: the goals they care
/// about and roughly how far they drive per month. Kept on the device in
/// UserDefaults (it describes the person, not a vehicle) and read after
/// sign-up by Home's plan card.
struct OnboardingPreferences: Equatable {
    enum Goal: String, CaseIterable, Identifiable {
        case fuelSavings
        case maintenance
        case expenses
        case askAI

        var id: String { rawValue }

        var title: String {
            switch self {
            case .fuelSavings: return "Yakıt tasarrufu"
            case .maintenance: return "Bakımı kaçırmamak"
            case .expenses: return "Giderleri takip"
            case .askAI: return "AI ile soru sormak"
            }
        }

        var systemImage: String {
            switch self {
            case .fuelSavings: return "leaf.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .expenses: return "creditcard.fill"
            case .askAI: return "sparkles"
            }
        }

        /// What the app does for this goal, for the plan summary.
        var planLine: String {
            switch self {
            case .fuelSavings: return "Depo kayıtlarından tüketimini hesaplayıp değişimleri göstereceğiz."
            case .maintenance: return "Bakım zamanlarını kilometre ve tarihe göre takip edeceğiz."
            case .expenses: return "Giderlerini kategoriye ve aya göre özetleyeceğiz."
            case .askAI: return "Asistan, kayıtlarına bakarak sorularını yanıtlayacak."
            }
        }
    }

    var goals: [Goal]
    var monthlyKm: Int

    static let defaultMonthlyKm = 1_500
    static let monthlyKmRange = 250...5_000

    /// Oil-change spacing used by `MaintenanceSchedule` (10.000 km or 12 months).
    private static let oilIntervalKm = 10_000

    var yearlyKm: Int { monthlyKm * 12 }

    /// Roughly how many months until the next oil change at this pace, capped
    /// at the schedule's 12-month limit.
    var monthsPerOilChange: Int {
        max(1, min(12, Self.oilIntervalKm / max(monthlyKm, 1)))
    }

    // MARK: - Storage

    private enum Key {
        static let goals = "onboarding.goals"
        static let monthlyKm = "onboarding.monthlyKm"
        static let planCardDismissed = "onboarding.planCardDismissed"
    }

    /// The saved answers, or `nil` if onboarding was skipped before answering.
    static func load(from defaults: UserDefaults = .standard) -> OnboardingPreferences? {
        guard defaults.object(forKey: Key.monthlyKm) != nil else { return nil }
        let goals = (defaults.stringArray(forKey: Key.goals) ?? []).compactMap(Goal.init(rawValue:))
        return OnboardingPreferences(goals: goals, monthlyKm: defaults.integer(forKey: Key.monthlyKm))
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(goals.map(\.rawValue), forKey: Key.goals)
        defaults.set(monthlyKm, forKey: Key.monthlyKm)
        defaults.set(false, forKey: Key.planCardDismissed)
    }

    static var isPlanCardDismissed: Bool {
        get { UserDefaults.standard.bool(forKey: Key.planCardDismissed) }
        set { UserDefaults.standard.set(newValue, forKey: Key.planCardDismissed) }
    }
}
