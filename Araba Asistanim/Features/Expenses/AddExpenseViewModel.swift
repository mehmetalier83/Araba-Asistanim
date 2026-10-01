import Combine
import Foundation

/// Form state for adding or editing a single expense. Doubles as the edit
/// view model — passing `existing` pre-fills every field and `buildExpense()`
/// preserves that record's id/createdAt while bumping `updatedAt`.
@MainActor
final class AddExpenseViewModel: ObservableObject {
    let vehicle: Vehicle

    @Published var category: ExpenseCategory?
    @Published var amountText: String = ""
    @Published var date: Date = .now
    @Published var mileageText: String
    @Published var serviceName: String = ""
    @Published var note: String = ""
    @Published var receiptImageData: Data?
    @Published var didAutoFillFromReceipt = false

    @Published private(set) var categoryError: String?
    @Published private(set) var amountError: String?
    @Published private(set) var mileageError: String?

    private let editingID: UUID?
    private let createdAt: Date

    init(vehicle: Vehicle, existing: ExpenseRecord? = nil) {
        self.vehicle = vehicle

        if let existing {
            self.category = existing.category
            self.amountText = Self.amountText(for: existing.amount)
            self.date = existing.date
            self.mileageText = existing.mileageKm.map(String.init) ?? ""
            self.serviceName = existing.serviceName ?? ""
            self.note = existing.note ?? ""
            self.receiptImageData = existing.receiptImageData
            self.editingID = existing.id
            self.createdAt = existing.createdAt
        } else {
            self.mileageText = String(vehicle.mileageKm)
            self.editingID = nil
            self.createdAt = .now
        }
    }

    var amountValue: Double { Double(amountText) ?? 0 }

    func clearCategoryError() { categoryError = nil }
    func clearAmountError() { amountError = nil }
    func clearMileageError() { mileageError = nil }

    /// Pre-fills whatever the receipt scan found — only into fields the user
    /// hasn't already typed something into, so a scan never clobbers a
    /// manual edit. Everything it sets remains an ordinary editable field.
    func applyScanResult(_ result: ReceiptScanner.ScanResult) {
        var didFill = false

        if amountText.isEmpty, let amount = result.amount {
            amountText = Self.amountText(for: amount)
            didFill = true
        }
        if category == nil, let category = result.category {
            self.category = category
            didFill = true
        }
        if serviceName.isEmpty, let merchant = result.merchantName {
            serviceName = merchant
            didFill = true
        }

        if didFill {
            didAutoFillFromReceipt = true
        }
    }

    func buildExpense() -> ExpenseRecord? {
        var isValid = true

        if category == nil {
            categoryError = "Bir kategori seç."
            isValid = false
        }

        if amountValue <= 0 {
            amountError = "Geçerli bir tutar gir."
            isValid = false
        }

        var mileage: Int?
        let trimmedMileage = mileageText.trimmingCharacters(in: .whitespaces)
        if !trimmedMileage.isEmpty {
            if let value = Int(trimmedMileage), value >= 0 {
                mileage = value
            } else {
                mileageError = "Geçerli bir kilometre gir."
                isValid = false
            }
        }

        guard isValid, let category else { return nil }

        let trimmedService = serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        return ExpenseRecord(
            id: editingID ?? UUID(),
            vehicleID: vehicle.id,
            category: category,
            amount: amountValue,
            date: date,
            mileageKm: mileage,
            serviceName: trimmedService.isEmpty ? nil : trimmedService,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            receiptImageData: receiptImageData,
            createdAt: createdAt,
            updatedAt: .now
        )
    }

    private static func amountText(for value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
