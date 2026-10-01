import Combine
import Foundation

/// Presentation state for the Add Vehicle form. Make and model come from
/// VehicleAPIServiceProtocol (a real, free vehicle registry); engine,
/// transmission, year and mileage stay as manual entry since no free API
/// reliably supplies trim-level specs or knows the user's own car's mileage.
@MainActor
final class AddVehicleViewModel: ObservableObject {
    @Published private(set) var makes: [String] = []
    @Published private(set) var isLoadingMakes = false
    @Published private(set) var makesError: String?

    @Published private(set) var selectedMake: String?
    @Published private(set) var models: [String] = []
    @Published private(set) var isLoadingModels = false
    @Published private(set) var modelsError: String?
    @Published private(set) var selectedModel: String?

    @Published var fuelType: FuelType = .gasoline
    @Published var engine = ""
    @Published var transmission = ""
    @Published var year = ""
    @Published var mileage = ""

    @Published private(set) var makeValidationError: String?
    @Published private(set) var modelValidationError: String?
    @Published private(set) var engineError: String?
    @Published private(set) var transmissionError: String?
    @Published private(set) var yearError: String?
    @Published private(set) var mileageError: String?

    private let apiService: VehicleAPIServiceProtocol

    /// `apiService` defaults to `nil` and falls back to the real NHTSA-backed
    /// implementation inside the body (rather than in the parameter list) —
    /// default-argument expressions are evaluated in a nonisolated context in
    /// Swift's concurrency model, even though this initializer is MainActor-isolated.
    init(apiService: VehicleAPIServiceProtocol? = nil) {
        self.apiService = apiService ?? NHTSAVehicleAPIService()
    }

    func loadMakes() async {
        guard !isLoadingMakes else { return }
        isLoadingMakes = true
        makesError = nil
        do {
            makes = try await apiService.fetchMakes()
        } catch {
            makesError = "Marka listesi yüklenemedi. İnternet bağlantını kontrol edip tekrar dene."
        }
        isLoadingMakes = false
    }

    func selectMake(_ make: String) {
        guard make != selectedMake else { return }
        selectedMake = make
        makeValidationError = nil
        selectedModel = nil
        modelValidationError = nil
        models = []
        modelsError = nil
        Task { await loadModels(for: make) }
    }

    func selectModel(_ model: String) {
        selectedModel = model
        modelValidationError = nil
    }

    private func loadModels(for make: String) async {
        isLoadingModels = true
        modelsError = nil
        do {
            let fetched = try await apiService.fetchModels(for: make)
            models = fetched
            if fetched.isEmpty {
                modelsError = "Bu marka için model bulunamadı."
            }
        } catch {
            modelsError = "Model listesi yüklenemedi. İnternet bağlantını kontrol edip tekrar dene."
        }
        isLoadingModels = false
    }

    func clearEngineError() { engineError = nil }
    func clearTransmissionError() { transmissionError = nil }
    func clearYearError() { yearError = nil }
    func clearMileageError() { mileageError = nil }

    func buildVehicle() -> Vehicle? {
        makeValidationError = selectedMake == nil ? "Marka seç." : nil
        modelValidationError = selectedModel == nil ? "Model seç." : nil
        engineError = engine.trimmingCharacters(in: .whitespaces).isEmpty ? "Motor bilgisi gir." : nil
        transmissionError = transmission.trimmingCharacters(in: .whitespaces).isEmpty ? "Şanzıman bilgisi gir." : nil

        let currentYear = Calendar.current.component(.year, from: .now)
        let yearValue = Int(year)
        yearError = (yearValue.map { (1980...currentYear + 1).contains($0) } ?? false)
            ? nil : "Geçerli bir yıl gir."

        let mileageValue = Int(mileage)
        mileageError = (mileageValue.map { $0 >= 0 } ?? false)
            ? nil : "Geçerli bir kilometre gir."

        guard let make = selectedMake, let model = selectedModel,
              makeValidationError == nil, modelValidationError == nil,
              engineError == nil, transmissionError == nil,
              yearError == nil, mileageError == nil,
              let yearValue, let mileageValue else { return nil }

        return Vehicle(
            make: make,
            model: model,
            year: yearValue,
            mileageKm: mileageValue,
            fuelType: fuelType,
            engine: engine.trimmingCharacters(in: .whitespaces),
            transmission: transmission.trimmingCharacters(in: .whitespaces)
        )
    }
}
