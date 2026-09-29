import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = VehiclesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.vehicles.isEmpty {
                    EmptyStateView(
                        systemImage: "car.2.fill",
                        title: "Garajın boş",
                        message: "Bakım, yakıt ve giderleri takip etmeye başlamak için ilk aracını ekle.",
                        actionTitle: "Araç Ekle"
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
            .navigationTitle("Araçlar")
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
                    .accessibilityLabel("Araç Ekle")
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
