import Foundation
import FirebaseFirestore

// MARK: - Firestore Database Repository for Todos
final class FirestoreTodoStore {
    static let shared = FirestoreTodoStore()
    private let database = Firestore.firestore()
    private let collectionName = "todos"

    private init() {}

    // Attach real-time snapshot listener scoped to creatorId
    func listenToUserTodos(
        userId: String,
        onRecords: @escaping ([TodoRecord]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        return database.collection(collectionName)
            .whereField("creatorId", isEqualTo: userId)
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }

                guard let documents = snapshot?.documents else {
                    onRecords([])
                    return
                }

                let records = documents.compactMap { doc -> TodoRecord? in
                    TodoRecord(docId: doc.documentID, data: doc.data())
                }

                onRecords(records)
            }
    }

    // Insert a new record
    func addTodoRecord(_ record: TodoRecord) async throws {
        _ = try await database.collection(collectionName).addDocument(data: record.asDictionary())
    }

    // Update an existing record
    func modifyTodoRecord(_ record: TodoRecord) async throws {
        guard let docId = record.id else { return }
        try await database.collection(collectionName).document(docId).setData(record.asDictionary(), merge: true)
    }

    // Toggle completion status
    func toggleStatus(recordId: String, currentStatus: Bool) async throws {
        try await database.collection(collectionName).document(recordId).updateData([
            "isDone": !currentStatus
        ])
    }

    // Remove record from Firestore
    func deleteTodoRecord(recordId: String) async throws {
        try await database.collection(collectionName).document(recordId).delete()
    }
}
