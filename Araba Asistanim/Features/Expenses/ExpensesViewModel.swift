import Combine
import Foundation

/// Presentation state for one vehicle's expense ledger — the Expenses list,
/// its detail screens, and Vehicle Detail's embedded Expenses section all
/// share one instance so an add/edit/delete in one place is reflected
/// everywhere else within that screen's lifetime. Sourced from PreviewData
/// in this phase — there is no backend or persistence yet.
@MainActor
final class ExpensesViewModel: ObservableObject {
    let vehicle: Vehicle
    @Published private(set) var expenses: [ExpenseRecord]

    /// `expenses` defaults to `nil` and falls back to PreviewData inside the
    /// body — default-argument expressions run in a nonisolated context in
    /// Swift's concurrency model, even though this initializer is MainActor-isolated.
    init(vehicle: Vehicle, expenses: [ExpenseRecord]? = nil) {
        self.vehicle = vehicle
        self.expenses = expenses ?? (AppSession.isDemoAccount
            ? PreviewData.allExpenses.filter { $0.vehicleID == vehicle.id }
            : [])
    }

    var thisMonthExpenses: [ExpenseRecord] {
        expenses.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }
    }

    var thisMonthTotal: Double {
        thisMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    var thisYearTotal: Double {
        expenses
            .filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .year) }
            .reduce(0) { $0 + $1.amount }
    }

    var allTimeTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var latestExpense: ExpenseRecord? {
        expenses.max { $0.date < $1.date }
    }

    func addExpense(_ expense: ExpenseRecord) {
        expenses.append(expense)
    }

    func updateExpense(_ expense: ExpenseRecord) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses[index] = expense
    }

    func deleteExpense(_ expense: ExpenseRecord) {
        expenses.removeAll { $0.id == expense.id }
    }
}
