import Foundation

/// A single fuel fill-up entry. All instances in this phase are mock/preview data.
struct FuelRecord: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let liters: Double
    let cost: Double
    let consumptionPer100Km: Double

    init(
        id: UUID = UUID(),
        date: Date,
        liters: Double,
        cost: Double,
        consumptionPer100Km: Double
    ) {
        self.id = id
        self.date = date
        self.liters = liters
        self.cost = cost
        self.consumptionPer100Km = consumptionPer100Km
    }
}
