import SwiftUI

/// A single maintenance event for a vehicle. Stored records are always
/// `.completed`; upcoming/overdue items are derived reminders
/// (see `MaintenanceSchedule`).
struct MaintenanceRecord: Identifiable, Hashable, Codable {
    let id: UUID
    var vehicleID: UUID
    var title: String
    var category: MaintenanceCategory
    var status: MaintenanceStatus
    var date: Date
    var mileageKm: Int
    /// Cost is only meaningful for completed records; upcoming/overdue items show nil.
    var cost: Double?
    var serviceName: String?
    var receiptImageData: Data?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        vehicleID: UUID,
        title: String,
        category: MaintenanceCategory,
        status: MaintenanceStatus = .completed,
        date: Date,
        mileageKm: Int,
        cost: Double?,
        serviceName: String? = nil,
        receiptImageData: Data? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.title = title
        self.category = category
        self.status = status
        self.date = date
        self.mileageKm = mileageKm
        self.cost = cost
        self.serviceName = serviceName
        self.receiptImageData = receiptImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum MaintenanceStatus: String, Hashable, Codable {
    case completed
    case upcoming
    case dueSoon
    case overdue

    var label: String {
        switch self {
        case .completed: return "Tamamlandı"
        case .upcoming: return "Planlı"
        case .dueSoon: return "Yaklaşıyor"
        case .overdue: return "Gecikti"
        }
    }

    var tagTone: TagView.Tone {
        switch self {
        case .completed: return .success
        case .upcoming: return .accent
        case .dueSoon: return .warning
        case .overdue: return .danger
        }
    }
}

enum MaintenanceCategory: String, CaseIterable, Hashable, Codable {
    case oilChange
    case brakeInspection
    case batteryReplacement
    case tireRotation
    case other

    var displayName: String {
        switch self {
        case .oilChange: return "Yağ Değişimi"
        case .brakeInspection: return "Fren Kontrolü"
        case .batteryReplacement: return "Akü Değişimi"
        case .tireRotation: return "Lastik Rotasyonu"
        case .other: return "Diğer"
        }
    }

    var systemImage: String {
        switch self {
        case .oilChange: return "drop.fill"
        case .brakeInspection: return "wrench.and.screwdriver.fill"
        case .batteryReplacement: return "bolt.fill"
        case .tireRotation: return "circle.grid.cross.fill"
        case .other: return "car.side.fill"
        }
    }

    /// Reuses the existing semantic/category palette, same approach as
    /// `ExpenseCategory.tintColor` — no new hues introduced here either.
    var tintColor: Color {
        switch self {
        case .oilChange: return AppTheme.warning
        case .brakeInspection: return AppTheme.error
        case .batteryReplacement: return AppTheme.categoryPurple
        case .tireRotation: return AppTheme.categoryTeal
        case .other: return AppTheme.textTertiary
        }
    }
}
