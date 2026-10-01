import Foundation

/// A single fuel fill-up for one vehicle. All instances in this phase are
/// mock/preview data — there is no backend or persistence yet.
///
/// `isFullTank` matters for future consumption analysis: an accurate L/100km
/// figure between two fill-ups is only meaningful when both are full-tank
/// fill-ups, so the flag is captured at entry time rather than guessed later.
struct FuelRecord: Identifiable, Hashable {
    let id: UUID
    var vehicleID: UUID
    var date: Date
    var liters: Double
    var cost: Double
    var mileageKm: Int
    var station: String?
    var isFullTank: Bool
    var receiptImageData: Data?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        vehicleID: UUID,
        date: Date = .now,
        liters: Double,
        cost: Double,
        mileageKm: Int,
        station: String? = nil,
        isFullTank: Bool = true,
        receiptImageData: Data? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.date = date
        self.liters = liters
        self.cost = cost
        self.mileageKm = mileageKm
        self.station = station
        self.isFullTank = isFullTank
        self.receiptImageData = receiptImageData
        self.createdAt = createdAt
    }
}
