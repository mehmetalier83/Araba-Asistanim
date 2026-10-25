import SwiftUI

/// Opens the right edit form for a ledger entry: a fuel fill-up edits in
/// AddFuelView (keeping liters and the full-tank flag), a completed service
/// in AddMaintenanceView, and anything else in AddExpenseView.
struct LedgerEditSheet: View {
    let vehicle: Vehicle
    let expense: ExpenseRecord

    @EnvironmentObject private var store: GarageStore

    var body: some View {
        if let fuel = store.fuelRecord(withID: expense.id) {
            AddFuelView(vehicle: vehicle, existingRecord: fuel) { store.updateFuel($0) }
        } else if let record = store.maintenanceRecord(withID: expense.id) {
            AddMaintenanceView(vehicle: vehicle, existingRecord: record) { store.updateMaintenance($0) }
        } else {
            AddExpenseView(vehicle: vehicle, existingExpense: expense) { store.updateSpending($0) }
        }
    }
}
