import Foundation

/// A vehicle owned by the user. All instances in this phase are mock/preview data.
struct Vehicle: Identifiable, Hashable {
    let id: UUID
    let make: String
    let model: String
    let year: Int
    let mileageKm: Int
    let fuelType: FuelType
    let engine: String
    let transmission: String

    var displayName: String { "\(make) \(model)" }

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        mileageKm: Int,
        fuelType: FuelType,
        engine: String,
        transmission: String
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.mileageKm = mileageKm
        self.fuelType = fuelType
        self.engine = engine
        self.transmission = transmission
    }
}

enum FuelType: String, CaseIterable, Hashable {
    case gasoline
    case diesel
    case hybrid
    case electric

    var displayName: String {
        switch self {
        case .gasoline: return "Gasoline"
        case .diesel: return "Diesel"
        case .hybrid: return "Hybrid"
        case .electric: return "Electric"
        }
    }
}
