import SwiftUI

struct VehicleListView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var isShowingAddVehicle = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.xs)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicleID: vehicle.id, allowsDelete: true)
            }
            .sheet(isPresented: $isShowingAddVehicle) {
                AddVehicleView { vehicle in
                    withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                        store.addVehicle(vehicle)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Araçlar")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Aracını ekle, tüm bilgilerini tek yerde yönet.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button {
                isShowingAddVehicle = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                    .background(LinearGradient.mascot(), in: Circle())
            }
            .buttonStyle(.appPressScale)
            .appShadow(AppShadow.primaryGlow)
            .accessibilityLabel("Araç Ekle")
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if store.vehicles.isEmpty {
                EmptyStateView(
                    systemImage: "car.fill",
                    title: "Garajın boş",
                    message: "Bakım, yakıt ve giderleri takip etmeye başlamak için ilk aracını ekle.",
                    actionTitle: "Araç Ekle"
                ) {
                    isShowingAddVehicle = true
                }
                .transition(.opacity)
            } else {
                List {
                    ForEach(store.vehicles) { vehicle in
                        // The link is laid under the card so the List doesn't
                        // add its own disclosure chevron outside the card.
                        VehicleCardView(vehicle: vehicle)
                            .background {
                                NavigationLink(value: vehicle) { EmptyView() }
                                    .opacity(0)
                            }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: AppSpacing.md, bottom: AppSpacing.sm, trailing: AppSpacing.md))
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.92).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                                    store.deleteVehicle(vehicle)
                                }
                                HapticFeedback.success()
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, AppSpacing.xs)
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    VehicleListView()
        .environmentObject(GarageStore.preview)
}

#Preview("Dark") {
    VehicleListView()
        .environmentObject(GarageStore.preview)
        .preferredColorScheme(.dark)
}
