import Foundation

/// A single maintenance event for a vehicle. All instances in this phase are mock/preview data.
struct MaintenanceRecord: Identifiable, Hashable {
    let id: UUID
    let title: String
    let category: MaintenanceCategory
    let status: MaintenanceStatus
    let date: Date
    let mileageKm: Int
    /// Cost is only meaningful for completed records; upcoming/overdue items show nil.
    let cost: Double?

    init(
        id: UUID = UUID(),
        title: String,
        category: MaintenanceCategory,
        status: MaintenanceStatus = .completed,
        date: Date,
        mileageKm: Int,
        cost: Double?
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.status = status
        self.date = date
        self.mileageKm = mileageKm
        self.cost = cost
    }
}

enum MaintenanceStatus: Hashable {
    case completed
    case dueSoon
    case overdue

    var label: String {
        switch self {
        case .completed: return "Completed"
        case .dueSoon: return "Due Soon"
        case .overdue: return "Overdue"
        }
    }

    var tagTone: TagView.Tone {
        switch self {
        case .completed: return .success
        case .dueSoon: return .warning
        case .overdue: return .danger
        }
    }
}

enum MaintenanceCategory: String, CaseIterable, Hashable {
    case oilChange
    case brakeInspection
    case batteryReplacement
    case tireRotation
    case other

    var systemImage: String {
        switch self {
        case .oilChange: return "drop.fill"
        case .brakeInspection: return "wrench.and.screwdriver.fill"
        case .batteryReplacement: return "bolt.fill"
        case .tireRotation: return "circle.grid.cross.fill"
        case .other: return "car.side.fill"
        }
    }
}
