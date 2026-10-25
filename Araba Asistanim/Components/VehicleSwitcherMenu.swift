import SwiftUI

/// Lets the user pick which vehicle Home, Bakım and Analiz show. Renders
/// nothing with fewer than two vehicles, since there's nothing to switch.
struct VehicleSwitcherMenu: View {
    @EnvironmentObject private var store: GarageStore

    var body: some View {
        if store.vehicles.count > 1 {
            Menu {
                Picker("Araç", selection: Binding(
                    get: { store.selectedVehicle?.id },
                    set: { store.selectedVehicleID = $0 }
                )) {
                    ForEach(store.vehicles) { vehicle in
                        Text(vehicle.displayName).tag(Optional(vehicle.id))
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(store.selectedVehicle?.displayName ?? "Araç Seç")
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                }
                .font(AppTypography.subheadline.weight(.medium))
            }
            .accessibilityLabel("Araç seç")
        }
    }
}
