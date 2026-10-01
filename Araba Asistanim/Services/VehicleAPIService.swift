import Foundation

protocol VehicleAPIServiceProtocol {
    func fetchMakes() async throws -> [String]
    func fetchModels(for make: String) async throws -> [String]
}

/// Fetches real passenger-car makes and models from NHTSA's vPIC API
/// (vpic.nhtsa.dot.gov) — a free, public, no-API-key vehicle registry
/// operated by the US Dept. of Transportation. This replaces the earlier
/// hand-written ~10-brand mock catalog with hundreds of real manufacturers
/// and their real model lineups.
///
/// It intentionally does NOT cover engine/trim-level data (e.g. "1.6 TDI 116
/// HP, DSG") — vPIC is a make/model registry, not a trim/spec catalog, and no
/// free API reliably provides that level of detail (it's typically a paid
/// commercial data feed). That's why "Add Vehicle" still asks for engine and
/// transmission directly rather than pretending to auto-fill them.
final class NHTSAVehicleAPIService: VehicleAPIServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://vpic.nhtsa.dot.gov/api/vehicles"

    /// Well-known acronym makes the API returns in ALL CAPS that shouldn't be
    /// title-cased like an ordinary word (e.g. "BMW", not "Bmw").
    private static let allCapsExceptions: Set<String> = ["BMW", "GMC", "MG", "RAM"]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchMakes() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/GetMakesForVehicleType/car?format=json") else {
            throw URLError(.badURL)
        }
        let response: MakesResponse = try await fetch(url)
        let names = Set(response.Results.map { Self.displayName(for: $0.MakeName) })
        return names.sorted()
    }

    func fetchModels(for make: String) async throws -> [String] {
        guard let encodedMake = make.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/GetModelsForMake/\(encodedMake)?format=json") else {
            throw URLError(.badURL)
        }
        let response: ModelsResponse = try await fetch(url)
        let names = Set(response.Results.map(\.Model_Name))
        return names.sorted()
    }

    private func fetch<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// The vehicle-type endpoint returns every make in full caps ("ASTON
    /// MARTIN"); title-case it for display while preserving known acronyms.
    private static func displayName(for rawMake: String) -> String {
        rawMake
            .split(separator: " ")
            .map { word -> String in
                let upper = word.uppercased()
                return allCapsExceptions.contains(upper) ? upper : word.capitalized
            }
            .joined(separator: " ")
    }
}

private struct MakesResponse: Decodable {
    struct Result: Decodable { let MakeName: String }
    let Results: [Result]
}

private struct ModelsResponse: Decodable {
    struct Result: Decodable { let Model_Name: String }
    let Results: [Result]
}
