import Foundation

/// A record type GarageStore persists. Each type lives in its own
/// collection (a JSON file locally, a sub-collection in Firestore).
protocol GarageEntity: Codable, Identifiable where ID == UUID {
    static var collection: String { get }
    /// Receipt photos are too large for a cloud document, so cloud
    /// repositories keep them on-device (see `ReceiptImageStore`).
    var receiptImageData: Data? { get set }
}

extension Vehicle: GarageEntity {
    static let collection = "vehicles"
    var receiptImageData: Data? {
        get { nil }
        set {}
    }
}
extension FuelRecord: GarageEntity { static let collection = "fuelRecords" }
extension MaintenanceRecord: GarageEntity { static let collection = "maintenanceRecords" }
extension ExpenseRecord: GarageEntity { static let collection = "expenses" }

/// Storage backend for one signed-in user's garage. GarageStore depends on
/// this protocol only, so the on-device store can be swapped for a cloud
/// one without touching any screen.
@MainActor
protocol GarageRepository {
    func fetchAll<T: GarageEntity>(_ type: T.Type) async throws -> [T]
    func upsert<T: GarageEntity>(_ item: T) async throws
    func delete<T: GarageEntity>(_ type: T.Type, id: UUID) async throws
    /// Removes every record for this user (account deletion).
    func deleteAll() async throws
}

/// Every collection GarageStore persists — used by `deleteAll()`.
enum GarageCollections {
    static let all = [Vehicle.collection, FuelRecord.collection, MaintenanceRecord.collection, ExpenseRecord.collection]
}

/// Keeps each collection as a JSON file under Application Support, scoped
/// per user so two accounts on one device never see each other's data.
final class LocalGarageRepository: GarageRepository {
    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userID: String, fileManager: FileManager = .default) {
        let base = (try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? fileManager.temporaryDirectory
        let safeID = userID.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? userID
        directory = base.appendingPathComponent("Garage", isDirectory: true).appendingPathComponent(safeID, isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func fetchAll<T: GarageEntity>(_ type: T.Type) async throws -> [T] {
        let url = fileURL(for: type)
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try decoder.decode([T].self, from: Data(contentsOf: url))
    }

    func upsert<T: GarageEntity>(_ item: T) async throws {
        var items = try await fetchAll(T.self)
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        try write(items)
    }

    func delete<T: GarageEntity>(_ type: T.Type, id: UUID) async throws {
        let items = try await fetchAll(type).filter { $0.id != id }
        try write(items)
    }

    func deleteAll() async throws {
        try FileManager.default.removeItem(at: directory)
    }

    private func write<T: GarageEntity>(_ items: [T]) throws {
        try encoder.encode(items).write(to: fileURL(for: T.self), options: [.atomic, .completeFileProtection])
    }

    private func fileURL<T: GarageEntity>(for type: T.Type) -> URL {
        directory.appendingPathComponent("\(T.collection).json")
    }
}

/// Non-persistent repository for SwiftUI previews and tests.
final class InMemoryGarageRepository: GarageRepository {
    private var storage: [String: [UUID: Data]] = [:]

    func fetchAll<T: GarageEntity>(_ type: T.Type) async throws -> [T] {
        try (storage[T.collection] ?? [:]).values.map { try JSONDecoder().decode(T.self, from: $0) }
    }

    func upsert<T: GarageEntity>(_ item: T) async throws {
        storage[T.collection, default: [:]][item.id] = try JSONEncoder().encode(item)
    }

    func delete<T: GarageEntity>(_ type: T.Type, id: UUID) async throws {
        storage[T.collection]?[id] = nil
    }

    func deleteAll() async throws {
        storage = [:]
    }
}
