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
            transmission: "8-Speed Automatic"
        ),
        Vehicle(
            make: "Toyota",
            model: "Corolla",
            year: 2021,
            mileageKm: 65_200,
            fuelType: .hybrid,
            engine: "1.8L Hybrid",
            transmission: "CVT Automatic"
        )
    ]

    /// The vehicle featured on the Home dashboard's summary card.
    static let featuredVehicle = vehicles[0]

    // MARK: - Maintenance

    static let maintenanceRecords: [MaintenanceRecord] = [
        MaintenanceRecord(
            title: "Tire Rotation",
            category: .tireRotation,
            status: .overdue,
            date: date(2026, 9, 1),
            mileageKm: 120_000,
            cost: nil
        ),
        MaintenanceRecord(
            title: "Oil Change",
            category: .oilChange,
            status: .dueSoon,
            date: date(2026, 10, 15),
            mileageKm: 123_000,
            cost: nil
        ),
        MaintenanceRecord(
            title: "Oil Change",
            category: .oilChange,
            status: .completed,
            date: date(2026, 8, 12),
            mileageKm: 120_000,
            cost: 7_450
        ),
        MaintenanceRecord(
            title: "Brake Inspection",
            category: .brakeInspection,
            status: .completed,
            date: date(2026, 4, 5),
            mileageKm: 116_000,
            cost: 4_800
        ),
        MaintenanceRecord(
            title: "Battery Replacement",
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
        ExpenseRecord(title: "Oil Change", category: .maintenance, amount: 7_450, date: date(2026, 8, 12)),
        ExpenseRecord(title: "Fuel", category: .fuel, amount: 2_350, date: date(2026, 9, 18)),
        ExpenseRecord(title: "Brake Inspection", category: .maintenance, amount: 4_800, date: date(2026, 4, 5))
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

    // MARK: - AI insight (Home)

    static let aiInsightMessage = "Your fuel consumption increased by 8% compared with last month."
    static let aiInsightDetail = """
    Based on your last two fuel entries, average consumption rose from 7.2 L/100 km \
    in July to 7.8 L/100 km in August — an increase of about 8%. This can be caused by \
    short trips, city driving, tire pressure, or upcoming maintenance needs.
    """

    // MARK: - Analytics

    static let monthlyExpenses: [MonthlyValue] = [
        MonthlyValue(month: "Jan", value: 4_500),
        MonthlyValue(month: "Feb", value: 6_200),
        MonthlyValue(month: "Mar", value: 3_800),
        MonthlyValue(month: "Apr", value: 8_400),
        MonthlyValue(month: "May", value: 5_600),
        MonthlyValue(month: "Jun", value: 7_850)
    ]

    static let monthlyFuelConsumption: [MonthlyValue] = [
        MonthlyValue(month: "Jan", value: 7.2),
        MonthlyValue(month: "Feb", value: 7.5),
        MonthlyValue(month: "Mar", value: 7.1),
        MonthlyValue(month: "Apr", value: 7.8),
        MonthlyValue(month: "May", value: 7.6),
        MonthlyValue(month: "Jun", value: 7.8)
    ]

    static let analyticsSummary: [Statistic] = [
        Statistic(title: "Monthly Spending", value: monthlyExpensesValue.formattedCurrencyTL(), systemImage: "banknote.fill"),
        Statistic(title: "Avg. Fuel Consumption", value: fuelConsumptionValue.formattedFuelConsumption(), systemImage: "fuelpump.fill"),
        Statistic(title: "Cost per Kilometer", value: costPerKmValue.formattedCostPerKm(), systemImage: "road.lanes")
    ]

    /// Spending grouped by category, for the Analytics "where is my money going" chart.
    static var spendingByCategory: [(category: ExpenseCategory, total: Double)] {
        let grouped = Dictionary(grouping: recentActivity, by: \.category)
        return grouped.map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    // MARK: - AI Assistant chat

    static let initialAssistantMessage = ChatMessage(
        role: .assistant,
        text: "Hello! I can help you understand your vehicle records and expenses."
    )

    static let suggestedQuestions: [String] = [
        "How much did I spend this year?",
        "Is my fuel consumption changing?",
        "What maintenance is coming up?",
        "Prepare a service summary."
    ]

    /// Canned assistant replies keyed by suggested question text.
    static let mockAssistantResponses: [String: String] = [
        "How much did I spend this year?":
            "Based on your records, you've spent approximately 82,750 TL so far this year across fuel, maintenance, and other expenses.",
        "Is my fuel consumption changing?":
            "Yes — it rose from 7.2 L/100 km in January to 7.8 L/100 km in June, an increase of about 8%. Short trips and city driving are common causes.",
        "What maintenance is coming up?":
            "A tire rotation is overdue, and an oil change is due soon at around 123,000 km.",
        "Prepare a service summary.":
            "Since January, your BMW 320i has had an oil change, a brake inspection, and a battery replacement, totaling 15,450 TL in maintenance costs."
    ]

    static let aiDisclaimer = "AI-generated information does not replace professional mechanical inspection."

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
