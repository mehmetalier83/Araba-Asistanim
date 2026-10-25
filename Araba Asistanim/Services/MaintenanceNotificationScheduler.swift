import Foundation
import UserNotifications

/// Local reminders for upcoming maintenance: three days before each dated
/// reminder, at 10:00. Rescheduled from scratch whenever the reminders change,
/// and only when the person has allowed notifications (asked during onboarding).
enum MaintenanceNotificationScheduler {
    private static let identifierPrefix = "maintenance."
    private static let leadDays = 3

    /// Shows the system permission prompt. Returns whether notifications are allowed.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func reschedule(_ reminders: [(record: MaintenanceRecord, vehicleName: String)], now: Date = .now) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: pending)

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }

        let calendar = Calendar.current
        for (record, vehicleName) in reminders where record.status != .completed {
            guard let day = calendar.date(byAdding: .day, value: -leadDays, to: record.date),
                  let fireDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: day),
                  fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(record.title) yaklaşıyor"
            content.body = "\(vehicleName) için \(record.title.lowercased(with: Locale(identifier: "tr_TR"))) zamanı \(record.date.formattedDayMonthYear()) tarihinde."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
                repeats: false
            )
            try? await center.add(UNNotificationRequest(identifier: identifierPrefix + record.id.uuidString, content: content, trigger: trigger))
        }
    }
}
