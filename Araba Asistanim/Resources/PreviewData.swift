import Foundation

/// Static mock/preview data for UI development.
///
/// TEMPORARY: everything in this file is placeholder content for building and
/// previewing the UI shell. It is not backed by persistence or a network
/// service, and must be replaced by real repository-backed data in a later
/// phase once backend and database integration are implemented.
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
            title: "Lastik Rotasyonu",
            category: .tireRotation,
            status: .overdue,
            date: date(2026, 9, 1),
            mileageKm: 120_000,
            cost: nil
        ),
        MaintenanceRecord(
            title: "Yağ Değişimi",
            category: .oilChange,
            status: .dueSoon,
            date: date(2026, 10, 15),
            mileageKm: 123_000,
            cost: nil
        ),
        MaintenanceRecord(
            title: "Yağ Değişimi",
            category: .oilChange,
            status: .completed,
            date: date(2026, 8, 12),
            mileageKm: 120_000,
            cost: 7_450
        ),
        MaintenanceRecord(
            title: "Fren Kontrolü",
            category: .brakeInspection,
            status: .completed,
            date: date(2026, 4, 5),
            mileageKm: 116_000,
            cost: 4_800
        ),
        MaintenanceRecord(
            title: "Akü Değişimi",
            category: .batteryReplacement,
            status: .completed,
            date: date(2026, 1, 10),
            mileageKm: 110_500,
            cost: 3_200
        )
    ]

    /// The single most urgent upcoming item, surfaced on the Home dashboard.
    static var nextMaintenanceItem: MaintenanceRecord? {
        maintenanceRecords.first { $0.status != .completed }
    }

    // MARK: - Recent activity (Home)

    static let recentActivity: [ExpenseRecord] = [
        ExpenseRecord(title: "Yağ Değişimi", category: .maintenance, amount: 7_450, date: date(2026, 8, 12)),
        ExpenseRecord(title: "Yakıt", category: .fuel, amount: 2_350, date: date(2026, 9, 18)),
        ExpenseRecord(title: "Fren Kontrolü", category: .maintenance, amount: 4_800, date: date(2026, 4, 5))
    ]

    // MARK: - Fuel records

    static let fuelRecords: [FuelRecord] = [
        FuelRecord(date: date(2026, 9, 18), liters: 42, cost: 2_350, consumptionPer100Km: 7.8),
        FuelRecord(date: date(2026, 8, 20), liters: 40, cost: 2_180, consumptionPer100Km: 7.6),
        FuelRecord(date: date(2026, 7, 22), liters: 41, cost: 2_260, consumptionPer100Km: 7.8)
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

    /// Canned assistant replies keyed by suggested question text.
    static let mockAssistantResponses: [String: String] = [
        "Bu yıl ne kadar harcadım?":
            "Kayıtlarına göre bu yıl yakıt, bakım ve diğer giderler dahil yaklaşık 82,750 TL harcadın.",
        "Yakıt tüketimim değişiyor mu?":
            "Evet — Ocak'ta 7.2 L/100 km olan tüketim Haziran'da 7.8 L/100 km'ye çıktı, yaklaşık %8'lik bir artış. Kısa mesafeler ve şehir içi sürüş yaygın nedenlerdir.",
        "Hangi bakımlar yaklaşıyor?":
            "Lastik rotasyonu gecikti, yağ değişimi ise yaklaşık 123,000 km'de yaklaşıyor.",
        "Bir servis özeti hazırla.":
            "Ocak ayından bu yana BMW 320i'nde bir yağ değişimi, bir fren kontrolü ve bir akü değişimi yapıldı; toplam bakım maliyeti 15,450 TL."
    ]

    static let aiDisclaimer = "Yapay zeka tarafından üretilen bilgiler, profesyonel mekanik kontrolün yerini tutmaz."

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
