import Combine
import Foundation

/// Presentation state for the AI Assistant screen. Answers are composed
/// on-device from the selected vehicle's own records (see `AssistantResponder`),
/// so every number in a reply is the user's real data — no network call.
@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage]
    @Published private(set) var isAssistantTyping = false

    let suggestedQuestions: [String]

    init(messages: [ChatMessage]? = nil, suggestedQuestions: [String]? = nil) {
        self.messages = messages ?? [PreviewData.initialAssistantMessage]
        self.suggestedQuestions = suggestedQuestions ?? PreviewData.suggestedQuestions
    }

    func ask(_ question: String, insights: GarageInsights?) {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isAssistantTyping else { return }

        messages.append(ChatMessage(role: .user, text: trimmed))
        let response = AssistantResponder.answer(to: trimmed, insights: insights)
        isAssistantTyping = true

        Task {
            try? await Task.sleep(for: .milliseconds(500))
            messages.append(ChatMessage(role: .assistant, text: response))
            isAssistantTyping = false
        }
    }
}

/// Keyword-based answers over GarageInsights. Covers the suggested questions
/// and their common rephrasings; anything else gets a short list of topics.
enum AssistantResponder {
    static func answer(to question: String, insights: GarageInsights?) -> String {
        guard let insights else {
            return "Önce Araçlar sekmesinden bir araç eklemelisin. Sonra harcamaların, yakıt tüketimin ve bakımların hakkında soru sorabilirsin."
        }
        let q = question.lowercased(with: Locale(identifier: "tr_TR"))
        let name = insights.vehicle.displayName

        if q.contains("özet") || q.contains("servis") || q.contains("geçmiş") {
            return serviceSummary(insights)
        }
        if q.contains("bakım") || q.contains("yaklaş") || q.contains("gecik") {
            let attention = insights.reminders.filter { $0.status != .upcoming }
            if attention.isEmpty, let next = insights.nextReminder {
                return "\(name) için acil bir bakım görünmüyor. \(insights.reminderSentence(next))"
            }
            if attention.isEmpty {
                return "Henüz bakım geçmişi olmadığı için bir sonraki bakımı hesaplayamıyorum. Bakım sekmesinden yaptığın son bakımları eklersen takip edebilirim."
            }
            return attention.map(insights.reminderSentence).joined(separator: "\n")
        }
        if q.contains("yakıt") || q.contains("tüketim") || q.contains("benzin") || q.contains("mazot") {
            guard let average = insights.averageConsumption() else {
                return "Tüketimi hesaplayabilmem için en az iki 'depo full' yakıt kaydı gerekiyor. Her dolumda kilometreyi de girersen L/100 km değerini çıkarabilirim."
            }
            var text = "\(name) için ortalama tüketimin \(average.formattedFuelConsumption())."
            if let latest = insights.latestConsumption, latest.changePercent != 0 {
                let direction = latest.changePercent > 0 ? "arttı" : "azaldı"
                text += " Son ayda önceki aya göre %\(Int(abs(latest.changePercent).rounded())) \(direction)."
                if latest.changePercent >= 5 {
                    text += " Kısa mesafeler, şehir içi sürüş, düşük lastik basıncı veya yaklaşan bakım tüketimi artırabilir."
                }
            }
            return text
        }
        if q.contains("harca") || q.contains("gider") || q.contains("masraf") || q.contains("para") || q.contains("maliyet") {
            var text = "Bu yıl \(name) için toplam \(insights.thisYearTotal.formattedCurrencyTL()) harcadın; bu ay \(insights.thisMonthTotal.formattedCurrencyTL())."
            if let top = insights.breakdown(since: Calendar.current.dateInterval(of: .year, for: .now)?.start).first {
                text += " En büyük kalem: \(top.category.displayName) (\(top.total.formattedCurrencyTL()))."
            }
            if let perKm = insights.costPerKm() {
                text += " Kilometre başına maliyetin yaklaşık \(perKm.formattedCostPerKm())."
            }
            return text
        }
        if q.contains("kilometre") || q.contains("km") {
            return "\(name) şu an \(insights.vehicle.mileageKm.formattedMileage()) gösteriyor."
        }
        return "Şimdilik harcamaların, yakıt tüketimin, yaklaşan bakımlar ve servis geçmişin hakkında cevap verebiliyorum. Örneğin \"Bu yıl ne kadar harcadım?\" diye sorabilirsin."
    }

    private static func serviceSummary(_ insights: GarageInsights) -> String {
        let history = insights.completedMaintenance
        guard !history.isEmpty else {
            return "\(insights.vehicle.displayName) için henüz kayıtlı bir bakım yok."
        }
        let total = history.compactMap(\.cost).reduce(0, +)
        let items = history.prefix(5).map { "• \($0.title), \($0.date.formattedDayMonthYear()), \($0.mileageKm.formattedMileage())" }
        return "\(insights.vehicle.displayName) için \(history.count) bakım kaydı var, toplam maliyet \(total.formattedCurrencyTL()).\n" + items.joined(separator: "\n")
    }
}
