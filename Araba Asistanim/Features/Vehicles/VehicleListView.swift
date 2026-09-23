import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = VehiclesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.vehicles.isEmpty {
                    EmptyStateView(
                        systemImage: "car.2.fill",
                        title: "Your garage is empty",
                        message: "Add your first vehicle to start tracking maintenance, fuel and expenses.",
                        actionTitle: "Add Vehicle"
                    ) {
                        viewModel.isShowingAddVehicle = true
                    }
                } else {
                    ScrollView {
                        VStack(spacing: AppSpacing.sm) {
                            ForEach(viewModel.vehicles) { vehicle in
                                NavigationLink(value: vehicle) {
                                    VehicleCardView(vehicle: vehicle)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Vehicles")
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicle: vehicle)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.isShowingAddVehicle = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Vehicle")
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddVehicle) {
                AddVehiclePlaceholderView()
            }
        }
    }
}

#Preview {
    VehicleListView()
}

#Preview("Dark") {
    VehicleListView()
        .preferredColorScheme(.dark)
}
