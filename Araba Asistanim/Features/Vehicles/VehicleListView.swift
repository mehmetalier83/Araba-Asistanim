import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = VehiclesViewModel()
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
            .background(AppTheme.groupedBackground)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicle: vehicle) {
                    viewModel.deleteVehicle(vehicle)
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddVehicle) {
                AddVehicleView { vehicle in
                    withAnimation(reduceMotion ? nil : AppAnimation.standard) {
                        viewModel.addVehicle(vehicle)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Araçlar")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Aracını ekle, tüm bilgilerini tek yerde yönet.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button {
                viewModel.isShowingAddVehicle = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: AppSizes.iconSmall, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: AppSizes.avatarSize, height: AppSizes.avatarSize)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
            }
            .buttonStyle(.appPressScale)
            .appShadow()
            .accessibilityLabel("Araç Ekle")
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if viewModel.vehicles.isEmpty {
                EmptyStateView(
                    systemImage: "car.fill",
                    title: "Garajın boş",
                    message: "Bakım, yakıt ve giderleri takip etmeye başlamak için ilk aracını ekle.",
                    actionTitle: "Araç Ekle"
                ) {
                    viewModel.isShowingAddVehicle = true
                }
                .transition(.opacity)
            } else {
                List {
                    ForEach(viewModel.vehicles) { vehicle in
                        NavigationLink(value: vehicle) {
                            VehicleCardView(vehicle: vehicle)
                        }
                        .buttonStyle(.appPressScale)
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
                                    viewModel.deleteVehicle(vehicle)
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
}

#Preview("Dark") {
    VehicleListView()
        .preferredColorScheme(.dark)
}
