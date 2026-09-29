import Foundation

/// The five top-level destinations in the main tab bar.
enum AppTab: String, CaseIterable, Hashable, Identifiable {
    case home
    case vehicles
    case maintenance
    case analytics
    case aiAssistant

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Ana Sayfa"
        case .vehicles: return "Araçlar"
        case .maintenance: return "Bakım"
        case .analytics: return "Analiz"
        case .aiAssistant: return "AI Asistan"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .vehicles: return "car.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .analytics: return "chart.bar.xaxis"
        case .aiAssistant: return "message.fill"
        }
    }
}
