import Foundation

/// Push destinations reachable from the Home tab's own navigation stack.
enum HomeRoute: Hashable {
    case settings
    case vehicleDetail(Vehicle)
}
