import Combine
import Foundation

/// Presentation-only state for the Home dashboard (which sheet is showing).
/// The data itself comes from GarageStore, so Home always reflects whatever
/// any tab has added.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var activeQuickAction: QuickActionType?
    @Published var isShowingInsightDetail = false
    @Published var isShowingAddVehicle = false

    func selectQuickAction(_ action: QuickActionType) {
        activeQuickAction = action
    }

    /// Time-of-day greeting for the header.
    static func greeting(at date: Date = .now) -> String {
        switch Calendar.current.component(.hour, from: date) {
        case 5..<12: return "Günaydın,"
        case 12..<18: return "İyi günler,"
        case 18..<23: return "İyi akşamlar,"
        default: return "İyi geceler,"
        }
    }
}
