import Foundation

// MARK: - Pending Operation Type

/// The kind of mutation that was queued while offline.
enum PendingOperationType: String, Codable {
    case toggle   // Toggle isChecked
    case create   // Add new item
    case delete   // Delete item by id
}

/// A single operation that could not be sent to the backend while offline.
struct PendingChecklistOperation: Codable, Identifiable {
    let id: String           // Unique queue entry ID
    let type: PendingOperationType
    let item: ChecklistItem  // The item payload (for delete only id is used)
    let queuedAt: Date
}

// MARK: - Queue

/// Persists offline mutations in UserDefaults and flushes them to the backend
/// as soon as connectivity is restored.
final class PendingChecklistQueue {

    static let shared = PendingChecklistQueue()

    private let storageKey = "safepath.pending_checklist_operations"
    private let storage = LocalStorageService.shared

    private init() {}

    // MARK: - Enqueue

    func enqueue(_ operation: PendingChecklistOperation) {
        var current = loadAll()
        // Avoid duplicate toggle entries — if we already have a toggle for
        // this item, remove the previous one (they cancel each other out
        // if we get an even number; keep the latest state instead).
        if operation.type == .toggle {
            current.removeAll { $0.type == .toggle && $0.item.id == operation.item.id }
        }
        current.append(operation)
        storage.save(current, forKey: storageKey)
        print("📥 [Queue] Enqueued \(operation.type.rawValue) for item '\(operation.item.name)'")
    }

    // MARK: - Flush

    /// Send all pending operations to the backend in order.
    /// Successfully sent operations are removed from the queue.
    func flush(using repository: PreparednessRepositoryProtocol) async {
        let operations = loadAll()
        guard !operations.isEmpty else { return }

        print("🔄 [Queue] Flushing \(operations.count) pending operation(s)...")

        var remaining: [PendingChecklistOperation] = []

        for op in operations {
            do {
                switch op.type {
                case .toggle:
                    _ = try await repository.updateItem(op.item)
                case .create:
                    _ = try await repository.createItem(op.item)
                case .delete:
                    try await repository.deleteItem(id: op.item.id)
                }
                print("✅ [Queue] Flushed \(op.type.rawValue) for '\(op.item.name)'")
            } catch {
                print("⚠️ [Queue] Failed to flush \(op.type.rawValue) for '\(op.item.name)': \(error.localizedDescription). Will retry later.")
                remaining.append(op)
            }
        }

        storage.save(remaining, forKey: storageKey)
    }

    // MARK: - Helpers

    func loadAll() -> [PendingChecklistOperation] {
        return storage.load(forKey: storageKey) ?? []
    }

    func pendingCount() -> Int {
        loadAll().count
    }

    func clear() {
        storage.remove(forKey: storageKey)
    }
}
