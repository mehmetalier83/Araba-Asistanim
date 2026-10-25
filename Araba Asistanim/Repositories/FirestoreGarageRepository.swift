import FirebaseFirestore
import Foundation

/// Cloud GarageRepository: each record is a document at
/// `users/{uid}/{collection}/{id}`. Firestore's offline cache (enabled in
/// FirebaseBootstrap) makes reads work without a connection, and writes are
/// applied to that cache immediately and synced once the device is online —
/// so saves are deliberately not awaited on the server.
final class FirestoreGarageRepository: GarageRepository {
    private let userRoot: DocumentReference
    private let receipts: ReceiptImageStore

    init(userID: String, firestore: Firestore = .firestore()) {
        userRoot = firestore.collection("users").document(userID)
        receipts = ReceiptImageStore(userID: userID)
    }

    func fetchAll<T: GarageEntity>(_ type: T.Type) async throws -> [T] {
        let snapshot = try await userRoot.collection(T.collection).getDocuments()
        return snapshot.documents.compactMap { document in
            guard var item = try? document.data(as: T.self) else { return nil }
            item.receiptImageData = receipts.image(for: item.id)
            return item
        }
    }

    func upsert<T: GarageEntity>(_ item: T) async throws {
        receipts.save(item.receiptImageData, for: item.id)
        var cloudCopy = item
        cloudCopy.receiptImageData = nil
        try userRoot.collection(T.collection).document(item.id.uuidString).setData(from: cloudCopy)
    }

    func delete<T: GarageEntity>(_ type: T.Type, id: UUID) async throws {
        receipts.save(nil, for: id)
        let document = userRoot.collection(T.collection).document(id.uuidString)
        // Removed from the local cache right away; the server ack isn't awaited.
        Task { try? await document.delete() }
    }

    /// Awaited on the server (unlike single writes), because the account is
    /// deleted right afterwards and these deletes must land while still signed in.
    func deleteAll() async throws {
        for collection in GarageCollections.all {
            let snapshot = try await userRoot.collection(collection).getDocuments()
            guard !snapshot.documents.isEmpty else { continue }
            let batch = userRoot.firestore.batch()
            snapshot.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
        receipts.deleteAll()
    }
}

/// Keeps receipt photos on-device, one file per record id, scoped per user.
final class ReceiptImageStore {
    private let directory: URL

    init(userID: String, fileManager: FileManager = .default) {
        let base = (try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? fileManager.temporaryDirectory
        let safeID = userID.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? userID
        directory = base.appendingPathComponent("Receipts", isDirectory: true).appendingPathComponent(safeID, isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func image(for id: UUID) -> Data? {
        try? Data(contentsOf: url(for: id))
    }

    func save(_ data: Data?, for id: UUID) {
        if let data {
            try? data.write(to: url(for: id), options: [.atomic, .completeFileProtection])
        } else {
            try? FileManager.default.removeItem(at: url(for: id))
        }
    }

    func deleteAll() {
        try? FileManager.default.removeItem(at: directory)
    }

    private func url(for id: UUID) -> URL {
        directory.appendingPathComponent(id.uuidString)
    }
}
