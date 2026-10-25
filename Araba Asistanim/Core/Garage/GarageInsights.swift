import Foundation

/// Pure calculations over one vehicle's records — monthly spending, fuel
/// consumption, category breakdowns and the short text insights shown on
/// Home and in the AI Assistant. Everything is derived, nothing is stored.
struct GarageInsights {
    let vehicle: Vehicle
    let spending: [ExpenseRecord]
    let fuelRecords: [FuelRecord]
    let reminders: [MaintenanceRecord]
    let completedMaintenance: [MaintenanceRecord]
    var now: Date = .now

    private var calendar: Calendar { .current }

    init(store: GarageStore, vehicle: Vehicle, now: Date = .now) {
        self.vehicle = vehicle
        self.spending = store.spending(for: vehicle.id)
        self.fuelRecords = store.fuelRecords(for: vehicle.id)
        self.reminders = store.reminders(for: vehicle.id)
        self.completedMaintenance = store.completedMaintenance(for: vehicle.id)
        self.now = now
    }

    var hasAnyData: Bool { !spending.isEmpty || !fuelRecords.isEmpty }

    // MARK: - Months

    /// The first day of each month in the window ending with the current month.
    func monthStarts(count: Int) -> [Date] {
        let current = startOfMonth(now)
        return (0..<max(count, 1)).reversed().compactMap {
            calendar.date(byAdding: .month, value: -$0, to: current)
        }
    }

    /// How many months back the oldest record goes (at least 1).
    var monthsOfHistory: Int {
        let dates = spending.map(\.date) + fuelRecords.map(\.date)
        guard let oldest = dates.min() else { return 1 }
        let months = calendar.dateComponents([.month], from: startOfMonth(oldest), to: startOfMonth(now)).month ?? 0
        return months + 1
    }

    func label(for monthStart: Date, includeYear: Bool) -> String {
        let names = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
        let parts = calendar.dateComponents([.year, .month], from: monthStart)
        let name = names[(parts.month ?? 1) - 1]
        guard includeYear, let year = parts.year else { return name }
        return "\(name) '\(String(year).suffix(2))"
    }

    // MARK: - Spending

    func total(inMonthOf date: Date) -> Double {
        spending.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }.reduce(0) { $0 + $1.amount }
    }

    var thisMonthTotal: Double { total(inMonthOf: now) }

    var lastMonthTotal: Double {
        total(inMonthOf: calendar.date(byAdding: .month, value: -1, to: now) ?? now)
    }

    var thisYearTotal: Double {
        spending.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }.reduce(0) { $0 + $1.amount }
    }

    var allTimeTotal: Double { spending.reduce(0) { $0 + $1.amount } }

    /// Month-over-month change in percent; 0 when there's no prior month to compare.
    var monthlySpendingChangePercent: Double {
        Self.percentChange(from: lastMonthTotal, to: thisMonthTotal)
    }

    func monthlySpending(months: Int) -> [MonthlyValue] {
        let includeYear = months > 12
        return monthStarts(count: months).map {
            MonthlyValue(month: label(for: $0, includeYear: includeYear), value: total(inMonthOf: $0))
        }
    }

    func breakdown(since start: Date? = nil) -> [(category: ExpenseCategory, total: Double)] {
        let records = start.map { start in spending.filter { $0.date >= start } } ?? spending
        let totals = Dictionary(grouping: records, by: \.category).mapValues { $0.reduce(0) { $0 + $1.amount } }
        return totals
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .map { (category: $0.key, total: $0.value) }
    }

    var thisMonthBreakdown: [(category: ExpenseCategory, total: Double)] {
        breakdown(since: startOfMonth(now))
    }

    /// Cost per km over the records since `start`, from the spread of logged
    /// odometer readings. `nil` until at least two readings differ.
    func costPerKm(since start: Date? = nil) -> Double? {
        let records = start.map { start in spending.filter { $0.date >= start } } ?? spending
        let readings = records.compactMap(\.mileageKm)
        guard let low = readings.min(), let high = readings.max(), high > low else { return nil }
        return records.reduce(0) { $0 + $1.amount } / Double(high - low)
    }

    // MARK: - Fuel consumption

    /// L/100 km between consecutive full-tank fill-ups. Liters from partial
    /// fill-ups in between are counted toward the next full one.
    var consumptionSamples: [(date: Date, value: Double)] {
        let sorted = fuelRecords.sorted { $0.mileageKm < $1.mileageKm }
        var samples: [(Date, Double)] = []
        var lastFull: FuelRecord?
        var litersSinceFull = 0.0

        for record in sorted {
            guard let previous = lastFull else {
                if record.isFullTank { lastFull = record }
                continue
            }
            litersSinceFull += record.liters
            if record.isFullTank {
                let distance = record.mileageKm - previous.mileageKm
                if distance > 0 {
                    samples.append((record.date, litersSinceFull / Double(distance) * 100))
                }
                lastFull = record
                litersSinceFull = 0
            }
        }
        return samples
    }

    func averageConsumption(since start: Date? = nil) -> Double? {
        let values = consumptionSamples.filter { start == nil || $0.date >= start! }.map(\.value)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    /// Average consumption per month, only for months that have a sample.
    func monthlyConsumption(months: Int) -> [MonthlyValue] {
        let includeYear = months > 12
        return monthStarts(count: months).compactMap { start in
            let values = consumptionSamples
                .filter { calendar.isDate($0.date, equalTo: start, toGranularity: .month) }
                .map(\.value)
            guard !values.isEmpty else { return nil }
            return MonthlyValue(month: label(for: start, includeYear: includeYear), value: values.reduce(0, +) / Double(values.count))
        }
    }

    /// The latest monthly average and its change vs. the month before it.
    var latestConsumption: (value: Double, changePercent: Double)? {
        let history = monthlyConsumption(months: monthsOfHistory)
        guard let latest = history.last else { return nil }
        let previous = history.dropLast().last
        return (latest.value, previous.map { Self.percentChange(from: $0.value, to: latest.value) } ?? 0)
    }

    // MARK: - Maintenance

    var nextReminder: MaintenanceRecord? { reminders.first }

    func remainingKm(to reminder: MaintenanceRecord) -> Int {
        reminder.mileageKm - vehicle.mileageKm
    }

    // MARK: - Text insights

    /// A one-line headline for Home's insight card.
    var headline: String {
        if let reminder = reminders.first(where: { $0.status == .overdue }) {
            return "\(reminder.title) zamanı geçti. Planlamayı unutma."
        }
        if let latest = latestConsumption, abs(latest.changePercent) >= 5 {
            let direction = latest.changePercent > 0 ? "arttı" : "azaldı"
            return "Yakıt tüketimin önceki aya göre %\(Int(abs(latest.changePercent).rounded())) \(direction)."
        }
        if lastMonthTotal > 0 && thisMonthTotal > 0 {
            let change = monthlySpendingChangePercent
            let direction = change > 0 ? "fazla" : "az"
            return "Bu ay geçen aya göre %\(Int(abs(change).rounded())) daha \(direction) harcadın."
        }
        if thisMonthTotal > 0 {
            return "Bu ay şimdiye kadar \(thisMonthTotal.formattedCurrencyTL()) harcadın."
        }
        return "Araç ve kayıt ekledikçe burada kişisel analizler görünecek."
    }

    /// The longer explanation shown when the insight card is tapped.
    var detail: String {
        var lines: [String] = []

        if thisMonthTotal > 0 || lastMonthTotal > 0 {
            lines.append("Bu ay \(thisMonthTotal.formattedCurrencyTL()), geçen ay \(lastMonthTotal.formattedCurrencyTL()) harcadın.")
        }
        if let top = thisMonthBreakdown.first {
            lines.append("Bu ayki en büyük gider kalemin: \(top.category.displayName) (\(top.total.formattedCurrencyTL())).")
        }
        if let average = averageConsumption() {
            lines.append("Ortalama yakıt tüketimin \(average.formattedFuelConsumption()).")
            if let latest = latestConsumption, latest.changePercent >= 5 {
                lines.append("Son dönemde tüketim artmış. Kısa mesafeler, şehir içi sürüş, düşük lastik basıncı veya yaklaşan bakım ihtiyacı bunun nedeni olabilir.")
            }
        } else {
            lines.append("Yakıt tüketimini hesaplayabilmem için en az iki 'depo full' yakıt kaydı gerekiyor.")
        }
        if let reminder = nextReminder {
            lines.append(reminderSentence(reminder))
        }
        return lines.isEmpty
            ? "Yakıt, bakım ve gider kayıtların arttıkça tüketim ve maliyet eğilimlerin burada özetlenecek."
            : lines.joined(separator: "\n\n")
    }

    func reminderSentence(_ reminder: MaintenanceRecord) -> String {
        guard reminder.tracksMileage else {
            return reminder.status == .overdue
                ? "\(reminder.title) gecikti (\(reminder.date.formattedDayMonthYear()))."
                : "Sıradaki bakım: \(reminder.title), \(reminder.date.formattedDayMonthYear())."
        }
        let km = remainingKm(to: reminder)
        let kmText = km > 0 ? "\(km.formattedMileage()) kaldı" : "\(abs(km).formattedMileage()) geçti"
        switch reminder.status {
        case .overdue:
            return "\(reminder.title) gecikti (\(reminder.date.formattedDayMonthYear()) · \(kmText))."
        default:
            return "Sıradaki bakım: \(reminder.title), \(reminder.date.formattedDayMonthYear()) ya da \(reminder.mileageKm.formattedMileage()) (\(kmText))."
        }
    }

    // MARK: - Helpers

    private func startOfMonth(_ date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    static func percentChange(from old: Double, to new: Double) -> Double {
        guard old > 0 else { return 0 }
        return (new - old) / old * 100
    }
}
