import Combine
import Foundation

/// Presentation state for the Vehicles tab. Sourced from PreviewData in this
/// phase — there is no backend or persistence yet.
@MainActor
final class VehiclesViewModel: ObservableObject {
    @Published private(set) var vehicles: [Vehicle]
    @Published var isShowingAddVehicle = false

    /// `vehicles` defaults to `nil` and falls back to PreviewData — but only
    /// for the seeded demo account; every other account starts with a
    /// genuinely empty garage. Default-argument expressions run in a
    /// nonisolated context in Swift's concurrency model, so this fallback is
    /// resolved inside the init body rather than in the parameter list, even
    /// though this initializer is itself MainActor-isolated.
    init(vehicles: [Vehicle]? = nil) {
        self.vehicles = vehicles ?? (AppSession.isDemoAccount ? PreviewData.vehicles : [])
    }

    /// Adds a vehicle to the in-memory list. There is no persistence layer yet,
    /// so this resets on next launch — consistent with the rest of this phase's
    /// mock data model.
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
    }
}
