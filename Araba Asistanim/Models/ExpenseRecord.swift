import SwiftUI

/// A single expense entry tied to one vehicle. All instances in this phase are
/// mock/preview data — there is no backend or persistence yet, matching the
/// rest of the app's current phase.
///
/// Shaped so a future AI-analysis layer can work directly off this model
/// without a redesign: every record carries a category, a vehicle, a date,
/// and a mileage snapshot, which is enough to compute trends ("12% more on
/// fuel this month") or cost-per-km without additional joins.
struct ExpenseRecord: Identifiable, Hashable {
    let id: UUID
    var vehicleID: UUID
    var category: ExpenseCategory
    var amount: Double
    var currency: String
    var date: Date
    var mileageKm: Int?
    var serviceName: String?
    var note: String?
    var receiptImageData: Data?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        vehicleID: UUID,
        category: ExpenseCategory,
        amount: Double,
        currency: String = "TRY",
        date: Date = .now,
        mileageKm: Int? = nil,
        serviceName: String? = nil,
        note: String? = nil,
        receiptImageData: Data? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.category = category
        self.amount = amount
        self.currency = currency
        self.date = date
        self.mileageKm = mileageKm
        self.serviceName = serviceName
        self.note = note
        self.receiptImageData = receiptImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum ExpenseCategory: String, CaseIterable, Hashable {
    case fuel
    case maintenance
    case tires
    case parking
    case toll
    case carWash
    case insurance
    case vehicleTax
    case parts
    case service
    case fine
    case other

    var displayName: String {
        switch self {
        case .fuel: return "Yakıt"
        case .maintenance: return "Bakım"
        case .tires: return "Lastik"
        case .parking: return "Otopark"
        case .toll: return "HGS/OGS"
        case .carWash: return "Araç Yıkama"
        case .insurance: return "Sigorta"
        case .vehicleTax: return "MTV"
        case .parts: return "Yedek Parça"
        case .service: return "Servis"
        case .fine: return "Ceza"
        case .other: return "Diğer"
        }
    }

    var systemImage: String {
        switch self {
        case .fuel: return "fuelpump.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .tires: return "circle.grid.cross.fill"
        case .parking: return "parkingsign.circle.fill"
        case .toll: return "road.lanes"
        case .carWash: return "bubbles.and.sparkles.fill"
        case .insurance: return "shield.fill"
        case .vehicleTax: return "building.columns.fill"
        case .parts: return "shippingbox.fill"
        case .service: return "wrench.adjustable.fill"
        case .fine: return "exclamationmark.triangle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// A single reusable color per category — shared by every chart/legend/
    /// picker that breaks spending down by category, so the mapping never
    /// drifts between screens. Mostly reuses the existing semantic palette;
    /// a couple of categories borrow two additional muted accents
    /// (`categoryTeal`, `categoryPurple`) since a 12-way picker needs more
    /// visual variety than five roles alone provide.
    var tintColor: Color {
        switch self {
        case .fuel, .carWash: return AppTheme.primary
        case .maintenance, .parts, .service: return AppTheme.warning
        case .tires, .toll: return AppTheme.categoryTeal
        case .insurance: return AppTheme.success
        case .vehicleTax: return AppTheme.categoryPurple
        case .fine: return AppTheme.error
        case .parking, .other: return AppTheme.textTertiary
        }
    }
}
