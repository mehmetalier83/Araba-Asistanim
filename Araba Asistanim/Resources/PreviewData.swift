import Foundation

/// Static mock/preview data for UI development.
///
/// Used for SwiftUI previews and to seed the built-in demo account's garage
/// on its first launch (see `GarageStore.load()`). Real accounts never see it.
enum PreviewData {

    // MARK: - Vehicles

    static let vehicles: [Vehicle] = [
        Vehicle(
            make: "BMW",
            model: "320i",
            year: 2018,
            mileageKm: 120_450,
            fuelType: .gasoline,
            engine: "2.0L Turbo I4",
            transmission: "8 İleri Otomatik"
        ),
        Vehicle(
            make: "Toyota",
            model: "Corolla",
            year: 2021,
            mileageKm: 65_200,
            fuelType: .hybrid,
            engine: "1.8L Hibrit",
            transmission: "CVT Otomatik"
        )
    ]

    /// The vehicle featured on the Home dashboard's summary card.
    static let featuredVehicle = vehicles[0]

    // MARK: - Maintenance

    static let maintenanceRecords: [MaintenanceRecord] = [
        MaintenanceRecord(
            vehicleID: vehicles[0].id,
            title: "Lastik Rotasyonu",
            category: .tireRotation,
            status: .overdue,
            date: date(2026, 9, 1),
            mileageKm: 120_000,
            cost: nil
        ),
        MaintenanceRecord(
            vehicleID: vehicles[0].id,
            title: "Yağ Değişimi",
            category: .oilChange,
            status: .dueSoon,
            date: date(2026, 10, 15),
            mileageKm: 123_000,
            cost: nil
        ),
        MaintenanceRecord(
            vehicleID: vehicles[0].id,
            title: "Yağ Değişimi",
            category: .oilChange,
            status: .completed,
            date: date(2026, 8, 12),
            mileageKm: 120_000,
            cost: 7_450,
            serviceName: "ABC Oto Servis"
        ),
        MaintenanceRecord(
            vehicleID: vehicles[0].id,
            title: "Fren Kontrolü",
            category: .brakeInspection,
            status: .completed,
            date: date(2026, 4, 5),
            mileageKm: 116_000,
            cost: 4_800,
            serviceName: "ABC Oto Servis"
        ),
        MaintenanceRecord(
            vehicleID: vehicles[0].id,
            title: "Akü Değişimi",
            category: .batteryReplacement,
            status: .completed,
            date: date(2026, 1, 10),
            mileageKm: 110_500,
            cost: 3_200,
            serviceName: "Bosch Car Service"
        )
    ]

    /// The single most urgent upcoming item, surfaced on the Home dashboard.
    static var nextMaintenanceItem: MaintenanceRecord? {
        maintenanceRecords.first { $0.status != .completed }
    }

    // MARK: - Expenses

    /// The full expense ledger across both vehicles — the richer, per-vehicle
    /// dataset behind the Expenses feature (list, detail, dashboard section).
    /// `recentActivity` below is just this list's 3 most recent entries.
    static let allExpenses: [ExpenseRecord] = {
        let bmw = vehicles[0].id
        let corolla = vehicles[1].id
        return [
            ExpenseRecord(vehicleID: bmw, category: .fuel, amount: 1_850, date: date(2026, 9, 30), mileageKm: 124_580, serviceName: "Shell"),
            ExpenseRecord(vehicleID: bmw, category: .maintenance, amount: 4_250, date: date(2026, 9, 22), mileageKm: 124_100, serviceName: "ABC Oto Servis", note: "10.000 km periyodik bakım"),
            ExpenseRecord(vehicleID: bmw, category: .fuel, amount: 2_350, date: date(2026, 9, 18), mileageKm: 123_400, serviceName: "Shell"),
            ExpenseRecord(vehicleID: bmw, category: .tires, amount: 3_600, date: date(2026, 9, 5), mileageKm: 122_900, serviceName: "Lastik Dünyası"),
            ExpenseRecord(vehicleID: bmw, category: .insurance, amount: 6_200, date: date(2026, 8, 12), mileageKm: 120_000, serviceName: "Anadolu Sigorta"),
            ExpenseRecord(vehicleID: bmw, category: .parking, amount: 120, date: date(2026, 8, 3), mileageKm: 119_500),
            ExpenseRecord(vehicleID: bmw, category: .toll, amount: 340, date: date(2026, 7, 28), mileageKm: 118_200),
            ExpenseRecord(vehicleID: bmw, category: .fine, amount: 900, date: date(2026, 6, 14), mileageKm: 115_000, note: "Hız cezası"),
            ExpenseRecord(vehicleID: bmw, category: .vehicleTax, amount: 4_800, date: date(2026, 1, 15), mileageKm: 108_000),
            ExpenseRecord(vehicleID: corolla, category: .fuel, amount: 1_450, date: date(2026, 9, 29), mileageKm: 65_100, serviceName: "BP"),
            ExpenseRecord(vehicleID: corolla, category: .carWash, amount: 250, date: date(2026, 9, 20), mileageKm: 64_800, serviceName: "Yıkama Dünyası"),
            ExpenseRecord(vehicleID: corolla, category: .service, amount: 2_100, date: date(2026, 8, 10), mileageKm: 63_500, serviceName: "Toyota Yetkili Servis")
        ]
    }()

    // MARK: - Recent activity (Home)

    /// The 3 most recent entries across the whole ledger, surfaced on the
    /// Home dashboard's "Son Hareketler" card.
    static var recentActivity: [ExpenseRecord] {
        Array(allExpenses.sorted { $0.date > $1.date }.prefix(3))
    }

    // MARK: - Fuel records

    static let fuelRecords: [FuelRecord] = [
        FuelRecord(vehicleID: vehicles[0].id, date: date(2026, 9, 18), liters: 42, cost: 2_350, mileageKm: 123_400, station: "Shell"),
        FuelRecord(vehicleID: vehicles[0].id, date: date(2026, 9, 2), liters: 40, cost: 2_180, mileageKm: 122_850, station: "Shell"),
        FuelRecord(vehicleID: vehicles[0].id, date: date(2026, 8, 20), liters: 38, cost: 2_070, mileageKm: 122_320, station: "Shell"),
        FuelRecord(vehicleID: vehicles[0].id, date: date(2026, 8, 3), liters: 41, cost: 2_260, mileageKm: 121_800, station: "BP"),
        FuelRecord(vehicleID: vehicles[1].id, date: date(2026, 9, 29), liters: 30, cost: 1_450, mileageKm: 65_100, station: "BP"),
        FuelRecord(vehicleID: vehicles[1].id, date: date(2026, 9, 1), liters: 32, cost: 1_520, mileageKm: 64_380, station: "BP")
    ]

    // MARK: - Key figures (raw values, shared by Home and Analytics)

    static let fuelConsumptionValue: Double = 7.8
    static let monthlyExpensesValue: Double = 7_850
    static let totalExpensesValue: Double = 82_750
    static let costPerKmValue: Double = 0.68

    /// Change vs. the previous month. Negative means improved (used lower);
    /// positive means increased. Both fuel and expenses read "lower is better".
    static let fuelConsumptionChangePercent: Double = -12
    static let monthlyExpensesChangePercent: Double = 8

    /// This month's spending broken down by category — a richer, standalone
    /// dataset (not just the 3 items shown in Recent Activity), used by the
    /// Home mini chart and the Analytics category chart alike.
    static let expenseBreakdown: [(category: ExpenseCategory, total: Double)] = [
        (.fuel, 3_200),
        (.maintenance, 2_150),
        (.insurance, 1_200),
        (.other, 1_300)
    ]

    // MARK: - AI insight (Home)

    static let aiInsightMessage = "Yakıt tüketimin geçen aya göre %8 arttı."
    static let aiInsightDetail = """
    Son iki yakıt kaydına göre ortalama tüketim Temmuz'da 7.2 L/100 km iken \
    Ağustos'ta 7.8 L/100 km'ye çıktı — yaklaşık %8'lik bir artış. Bunun nedeni \
    kısa mesafeler, şehir içi sürüş, lastik basıncı veya yaklaşan bakım ihtiyaçları olabilir.
    """

    // MARK: - Analytics

    static let monthlyExpenses: [MonthlyValue] = [
        MonthlyValue(month: "Oca", value: 4_500),
        MonthlyValue(month: "Şub", value: 6_200),
        MonthlyValue(month: "Mar", value: 3_800),
        MonthlyValue(month: "Nis", value: 8_400),
        MonthlyValue(month: "May", value: 5_600),
        MonthlyValue(month: "Haz", value: 7_850)
    ]

    static let monthlyFuelConsumption: [MonthlyValue] = [
        MonthlyValue(month: "Oca", value: 7.2),
        MonthlyValue(month: "Şub", value: 7.5),
        MonthlyValue(month: "Mar", value: 7.1),
        MonthlyValue(month: "Nis", value: 7.8),
        MonthlyValue(month: "May", value: 7.6),
        MonthlyValue(month: "Haz", value: 7.8)
    ]

    static let analyticsSummary: [Statistic] = [
        Statistic(title: "Aylık Harcama", value: monthlyExpensesValue.formattedCurrencyTL(), systemImage: "banknote.fill"),
        Statistic(title: "Ort. Yakıt Tüketimi", value: fuelConsumptionValue.formattedFuelConsumption(), systemImage: "fuelpump.fill"),
        Statistic(title: "Kilometre Başı Maliyet", value: costPerKmValue.formattedCostPerKm(), systemImage: "road.lanes")
    ]

    // MARK: - AI Assistant chat

    static let initialAssistantMessage = ChatMessage(
        role: .assistant,
        text: "Merhaba! Araç kayıtlarını ve giderlerini anlamana yardımcı olabilirim."
    )

    static let suggestedQuestions: [String] = [
        "Bu yıl ne kadar harcadım?",
        "Yakıt tüketimim değişiyor mu?",
        "Hangi bakımlar yaklaşıyor?",
        "Bir servis özeti hazırla."
    ]

    static let aiDisclaimer = "Yapay zeka tarafından üretilen bilgiler, profesyonel mekanik kontrolün yerini tutmaz."

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
