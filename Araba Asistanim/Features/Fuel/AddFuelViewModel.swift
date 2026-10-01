import Combine
import Foundation

/// Form state for logging a fuel fill-up. Mirrors `AddExpenseViewModel`'s
/// shape and validation style so the two "Add" flows feel like one system.
@MainActor
final class AddFuelViewModel: ObservableObject {
    let vehicle: Vehicle

    @Published var costText: String = ""
    @Published var litersText: String = ""
    @Published var date: Date = .now
    @Published var mileageText: String
    @Published var station: String = ""
    @Published var isFullTank: Bool = true
    @Published var receiptImageData: Data?
    @Published var didAutoFillFromReceipt = false

    @Published private(set) var costError: String?
    @Published private(set) var litersError: String?
    @Published private(set) var mileageError: String?

    private let editingID: UUID?
    private let createdAt: Date

    init(vehicle: Vehicle, existing: FuelRecord? = nil) {
        self.vehicle = vehicle

        if let existing {
            self.costText = Self.decimalText(for: existing.cost)
            self.litersText = Self.decimalText(for: existing.liters)
            self.date = existing.date
            self.mileageText = String(existing.mileageKm)
            self.station = existing.station ?? ""
            self.isFullTank = existing.isFullTank
            self.receiptImageData = existing.receiptImageData
            self.editingID = existing.id
            self.createdAt = existing.createdAt
        } else {
            self.mileageText = String(vehicle.mileageKm)
            self.editingID = nil
            self.createdAt = .now
        }
    }

    var costValue: Double { Double(costText) ?? 0 }
    var litersValue: Double { Double(litersText) ?? 0 }

    /// A live "price per liter" hint shown once both fields have a value —
    /// a small, free piece of feedback that this is a well-thought-out fuel
    /// form, not a generic amount/quantity pair.
    var pricePerLiterText: String? {
        guard costValue > 0, litersValue > 0 else { return nil }
        return String(format: "≈ %.2f TL/L", costValue / litersValue)
    }

    func clearCostError() { costError = nil }
    func clearLitersError() { litersError = nil }
    func clearMileageError() { mileageError = nil }

    /// Pre-fills whatever the receipt scan found — only into fields the user
    /// hasn't already typed something into, so a scan never clobbers a
    /// manual edit. Everything it sets remains an ordinary editable field.
    func applyScanResult(_ result: ReceiptScanner.ScanResult) {
        var didFill = false

        if costText.isEmpty, let amount = result.amount {
            costText = Self.decimalText(for: amount)
            didFill = true
        }
        if litersText.isEmpty, let liters = result.liters {
            litersText = Self.decimalText(for: liters)
            didFill = true
        }
        if station.isEmpty, let merchant = result.merchantName {
            station = merchant
            didFill = true
        }

        if didFill {
            didAutoFillFromReceipt = true
        }
    }

    func buildFuelRecord() -> FuelRecord? {
        var isValid = true

        if costValue <= 0 {
            costError = "Geçerli bir tutar gir."
            isValid = false
        }

        if litersValue <= 0 {
            litersError = "Geçerli bir litre miktarı gir."
            isValid = false
        }

        var mileage = 0
        let trimmedMileage = mileageText.trimmingCharacters(in: .whitespaces)
        if let value = Int(trimmedMileage), value >= 0 {
            mileage = value
        } else {
            mileageError = "Geçerli bir kilometre gir."
            isValid = false
        }

        guard isValid else { return nil }

        let trimmedStation = station.trimmingCharacters(in: .whitespacesAndNewlines)

        return FuelRecord(
            id: editingID ?? UUID(),
            vehicleID: vehicle.id,
            date: date,
            liters: litersValue,
            cost: costValue,
            mileageKm: mileage,
            station: trimmedStation.isEmpty ? nil : trimmedStation,
            isFullTank: isFullTank,
            receiptImageData: receiptImageData,
            createdAt: createdAt
        )
    }

    private static func decimalText(for value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.2f", value)
    }
}
