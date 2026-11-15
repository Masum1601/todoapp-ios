import Foundation
import Combine
import FirebaseFirestore

// MARK: - Display Filter
enum DisplayFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case completed = "Done"

    var id: String { self.rawValue }
}

// MARK: - Todo Dashboard ViewModel
@MainActor
final class TodoDashboardViewModel: ObservableObject {
    @Published var records: [TodoRecord] = []
    @Published var currentFilter: DisplayFilter = .all
    @Published var isRefreshing: Bool = false
    @Published var alertError: String?

    private let store = FirestoreTodoStore.shared
    private let authenticator = FirebaseAuthenticator.shared
    private var listener: ListenerRegistration?

    init() {
        bindRealtimeListener()
    }

    deinit {
        listener?.remove()
    }

    func bindRealtimeListener() {
        guard let userId = authenticator.activeUserId else {
            self.records = []
            return
        }

        isRefreshing = true
        listener?.remove()

        listener = store.listenToUserTodos(
            userId: userId,
            onRecords: { [weak self] updatedRecords in
                Task { @MainActor in
                    self?.records = updatedRecords
                    self?.isRefreshing = false
                }
            },
            onError: { [weak self] error in
                Task { @MainActor in
                    self?.alertError = error.localizedDescription
                    self?.isRefreshing = false
                }
            }
        )
    }

    var filteredRecords: [TodoRecord] {
        records.filter { record in
            switch currentFilter {
            case .all: return true
            case .pending: return !record.isDone
            case .completed: return record.isDone
            }
        }
    }

    var pendingCount: Int {
        records.filter { !$0.isDone }.count
    }

    var completedCount: Int {
        records.filter { $0.isDone }.count
    }

    var totalCount: Int {
        records.count
    }

    func createTodo(title: String, description: String, priority: PriorityLevel) async {
        guard let userId = authenticator.activeUserId else { return }

        let newRecord = TodoRecord(
            title: title,
            descriptionText: description,
            isDone: false,
            priority: priority,
            dateCreated: Date(),
            creatorId: userId
        )

        do {
            try await store.addTodoRecord(newRecord)
        } catch {
            self.alertError = error.localizedDescription
        }
    }

    func saveEdit(record: TodoRecord) async {
        do {
            try await store.modifyTodoRecord(record)
        } catch {
            self.alertError = error.localizedDescription
        }
    }

    func toggleDone(for record: TodoRecord) async {
        guard let docId = record.id else { return }
        do {
            try await store.toggleStatus(recordId: docId, currentStatus: record.isDone)
        } catch {
            self.alertError = error.localizedDescription
        }
    }

    func remove(record: TodoRecord) async {
        guard let docId = record.id else { return }
        do {
            try await store.deleteTodoRecord(recordId: docId)
        } catch {
            self.alertError = error.localizedDescription
        }
    }
}
