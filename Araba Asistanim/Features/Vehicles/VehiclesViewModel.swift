import Combine
import Foundation

/// Presentation state for the Vehicles tab. Sourced from PreviewData in this
/// phase — there is no backend or persistence yet.
@MainActor
final class VehiclesViewModel: ObservableObject {
    @Published private(set) var vehicles: [Vehicle]
    @Published var isShowingAddVehicle = false

    /// `vehicles` defaults to `nil` and falls back to PreviewData inside the
    /// body — default-argument expressions run in a nonisolated context in
    /// Swift's concurrency model, even though this initializer is MainActor-isolated.
    init(vehicles: [Vehicle]? = nil) {
        self.vehicles = vehicles ?? PreviewData.vehicles
    }
}
