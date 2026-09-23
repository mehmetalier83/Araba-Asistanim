import SwiftUI

/// A temporary placeholder for the future "Add Vehicle" flow.
struct AddVehiclePlaceholderView: View {
    var body: some View {
        PlaceholderSheet(
            systemImage: "car.badge.plus",
            title: "Add Vehicle",
            message: "Adding a new vehicle isn't implemented yet. This will be available once the data layer is built."
        )
    }
}

#Preview {
    AddVehiclePlaceholderView()
}
