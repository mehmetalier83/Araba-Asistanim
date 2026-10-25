import Foundation

/// Derives upcoming/overdue maintenance reminders from the completed history:
/// each category has a typical service interval, and the next one is due that
/// many km or months after the most recent completed service of that kind.
enum MaintenanceSchedule {
    struct Interval {
        let km: Int?
        let months: Int
    }

    static func interval(for category: MaintenanceCategory) -> Interval? {
        switch category {
        case .oilChange: return Interval(km: 10_000, months: 12)
        case .brakeInspection: return Interval(km: 20_000, months: 12)
        case .batteryReplacement: return Interval(km: nil, months: 48)
        case .tireRotation: return Interval(km: 10_000, months: 6)
        case .other: return nil
        }
    }

    /// Within this distance or time of the due point, a reminder is "due soon".
    static let dueSoonKm = 1_500
    static let dueSoonDays = 30

    static func reminders(for vehicle: Vehicle, history: [MaintenanceRecord], now: Date = .now) -> [MaintenanceRecord] {
        let completed = history.filter { $0.vehicleID == vehicle.id && $0.status == .completed }
        let calendar = Calendar.current

        return MaintenanceCategory.allCases.compactMap { category -> MaintenanceRecord? in
            guard
                let interval = interval(for: category),
                let last = completed.filter({ $0.category == category }).max(by: { $0.date < $1.date })
            else { return nil }

            let dueDate = calendar.date(byAdding: .month, value: interval.months, to: last.date) ?? last.date
            let dueKm = interval.km.map { last.mileageKm + $0 }

            let daysLeft = calendar.dateComponents([.day], from: now, to: dueDate).day ?? 0
            let kmLeft = dueKm.map { $0 - vehicle.mileageKm }

            let status: MaintenanceStatus
            if daysLeft < 0 || (kmLeft ?? 1) <= 0 {
                status = .overdue
            } else if daysLeft <= dueSoonDays || (kmLeft ?? .max) <= dueSoonKm {
                status = .dueSoon
            } else {
                status = .upcoming
            }

            return MaintenanceRecord(
                id: reminderID(vehicleID: vehicle.id, category: category),
                vehicleID: vehicle.id,
                title: category.displayName,
                category: category,
                status: status,
                date: dueDate,
                mileageKm: dueKm ?? vehicle.mileageKm,
                cost: nil
            )
        }
        .sorted { lhs, rhs in
            if lhs.status.urgency != rhs.status.urgency { return lhs.status.urgency > rhs.status.urgency }
            return lhs.date < rhs.date
        }
    }

    /// Stable per vehicle + category, so SwiftUI identity survives recomputation.
    private static func reminderID(vehicleID: UUID, category: MaintenanceCategory) -> UUID {
        var bytes = vehicleID.uuid
        bytes.15 ^= UInt8((MaintenanceCategory.allCases.firstIndex(of: category) ?? 0) + 1)
        bytes.14 ^= 0xA5
        return UUID(uuid: bytes)
    }
}

extension MaintenanceRecord {
    /// False for a time-only reminder (e.g. battery every 48 months), whose
    /// mileage isn't a meaningful due point and shouldn't be shown.
    var tracksMileage: Bool {
        status == .completed || MaintenanceSchedule.interval(for: category)?.km != nil
    }

    /// "5 Eylül 2027 · 130,000 km", or just the date when mileage doesn't apply.
    var dueSummary: String {
        tracksMileage
            ? "\(date.formattedDayMonthYear()) · \(mileageKm.formattedMileage())"
            : date.formattedDayMonthYear()
    }
}

extension MaintenanceStatus {
    var urgency: Int {
        switch self {
        case .overdue: return 3
        case .dueSoon: return 2
        case .upcoming: return 1
        case .completed: return 0
        }
    }
}
