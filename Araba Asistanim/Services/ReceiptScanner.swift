import UIKit
import Vision

/// On-device receipt OCR using the Vision framework — no network call, no
/// backend, consistent with this app's current mock-data phase. Reads a
/// receipt/invoice photo and makes a best-effort guess at the amount, the
/// expense category, the station/merchant name, and (for fuel receipts) the
/// liter quantity.
///
/// This is explicitly a *guess*: receipt photos are often skewed, glare-hit,
/// or printed on thermal paper that fades, so every field this produces is
/// pre-filled into an ordinary editable text field, never locked — the
/// camera can misread, and the person reviewing the form is the final word.
enum ReceiptScanner {
    struct ScanResult {
        var amount: Double?
        var category: ExpenseCategory?
        var maintenanceCategory: MaintenanceCategory?
        var merchantName: String?
        var liters: Double?
    }

    static func scan(_ image: UIImage) async -> ScanResult? {
        guard let cgImage = image.cgImage else { return nil }

        let lines: [String] = await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["tr-TR", "en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }

        guard !lines.isEmpty else { return nil }

        let fullText = lines.joined(separator: "\n")
        return ScanResult(
            amount: extractAmount(from: lines),
            category: extractCategory(from: fullText),
            maintenanceCategory: extractMaintenanceCategory(from: fullText),
            merchantName: extractMerchant(from: fullText),
            liters: extractLiters(from: lines)
        )
    }

    // MARK: - Amount

    private static let totalKeywords = ["GENEL TOPLAM", "TOPLAM", "ÖDENEN TUTAR", "ÖDENEN", "TUTAR"]
    private static let datePattern = try? NSRegularExpression(pattern: #"\d{1,2}[./]\d{1,2}[./]\d{2,4}"#)
    private static let moneyPattern = try? NSRegularExpression(pattern: #"\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?"#)

    private static func extractAmount(from lines: [String]) -> Double? {
        let nonDateLines = lines.filter { !containsDate($0) }

        let keywordLines = nonDateLines.filter { line in
            let upper = line.uppercased(with: Locale(identifier: "tr_TR"))
            return totalKeywords.contains { upper.contains($0) }
        }

        if let fromKeyword = keywordLines.compactMap({ monetaryValues(in: $0).max() }).max() {
            return fromKeyword
        }

        return nonDateLines.compactMap { monetaryValues(in: $0).max() }.max()
    }

    private static func containsDate(_ line: String) -> Bool {
        guard let datePattern else { return false }
        let range = NSRange(location: 0, length: (line as NSString).length)
        return datePattern.firstMatch(in: line, range: range) != nil
    }

    private static func monetaryValues(in line: String) -> [Double] {
        guard let moneyPattern else { return [] }
        let nsLine = line as NSString
        let matches = moneyPattern.matches(in: line, range: NSRange(location: 0, length: nsLine.length))
        return matches.compactMap { parseTurkishNumber(nsLine.substring(with: $0.range)) }
    }

    /// Parses a number token that may use either "1.250,50" (Turkish:
    /// period thousands, comma decimal) or "1,250.50" / "125.50" conventions.
    private static func parseTurkishNumber(_ token: String) -> Double? {
        var cleaned = token
        if cleaned.contains(",") && cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        } else if cleaned.contains(",") {
            let parts = cleaned.split(separator: ",")
            cleaned = (parts.count == 2 && parts[1].count == 2)
                ? cleaned.replacingOccurrences(of: ",", with: ".")
                : cleaned.replacingOccurrences(of: ",", with: "")
        } else if cleaned.contains(".") {
            let parts = cleaned.split(separator: ".")
            if !(parts.count == 2 && parts[1].count == 2) {
                cleaned = cleaned.replacingOccurrences(of: ".", with: "")
            }
        }
        guard let value = Double(cleaned), value > 0 else { return nil }
        return value
    }

    // MARK: - Category

    private static let categoryKeywords: [(ExpenseCategory, [String])] = [
        (.fuel, ["AKARYAKIT", "BENZİN", "MOTORİN", "LPG", "SHELL", "OPET", "PETROL OFİSİ", "AYGAZ", "YAKIT", "LUKOIL", "ALPET"]),
        (.carWash, ["YIKAMA"]),
        (.tires, ["LASTİK"]),
        (.parking, ["OTOPARK"]),
        (.toll, ["HGS", "OGS"]),
        (.insurance, ["SİGORTA"]),
        (.vehicleTax, ["MTV", "VERGİ DAİRESİ"]),
        (.fine, ["TRAFİK CEZASI", "İDARİ PARA CEZASI", "CEZA TUTANAĞI"]),
        (.parts, ["YEDEK PARÇA"]),
        (.maintenance, ["BAKIM", "YAĞ DEĞİŞİMİ"]),
        (.service, ["OTO SERVİS", "SERVİS", "TAMİR"])
    ]

    private static func extractCategory(from fullText: String) -> ExpenseCategory? {
        let upper = fullText.uppercased(with: Locale(identifier: "tr_TR"))
        for (category, keywords) in categoryKeywords where keywords.contains(where: { upper.contains($0) }) {
            return category
        }
        return nil
    }

    // MARK: - Maintenance category

    private static let maintenanceCategoryKeywords: [(MaintenanceCategory, [String])] = [
        (.oilChange, ["YAĞ DEĞİŞİMİ", "YAĞ"]),
        (.brakeInspection, ["FREN"]),
        (.batteryReplacement, ["AKÜ"]),
        (.tireRotation, ["LASTİK"])
    ]

    private static func extractMaintenanceCategory(from fullText: String) -> MaintenanceCategory? {
        let upper = fullText.uppercased(with: Locale(identifier: "tr_TR"))
        for (category, keywords) in maintenanceCategoryKeywords where keywords.contains(where: { upper.contains($0) }) {
            return category
        }
        return nil
    }

    // MARK: - Merchant

    private static let knownFuelBrands = ["Shell", "BP", "Opet", "Total", "Petrol Ofisi", "Aygaz", "Lukoil", "Alpet"]

    private static func extractMerchant(from fullText: String) -> String? {
        knownFuelBrands.first { fullText.range(of: $0, options: .caseInsensitive) != nil }
    }

    // MARK: - Liters (fuel receipts only)

    private static func extractLiters(from lines: [String]) -> Double? {
        for line in lines {
            let upper = line.uppercased(with: Locale(identifier: "tr_TR"))
            guard upper.contains("LT") || upper.contains("LİTRE") else { continue }
            if let value = monetaryValues(in: line).first {
                return value
            }
        }
        return nil
    }
}
