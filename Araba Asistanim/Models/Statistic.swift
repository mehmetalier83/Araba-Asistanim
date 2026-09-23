import Foundation

/// A pre-formatted title/value pair displayed in a StatisticCard.
/// The value is stored pre-formatted since units differ per statistic (km, TL, L/100km).
struct Statistic: Identifiable, Hashable {
    var id: String { title }
    let title: String
    let value: String
    let systemImage: String
}
