import Combine
import Foundation
import SwiftData

@MainActor
final class PreparednessViewModel: ObservableObject {

    // MARK: - Published State

    /// Hardcoded mandatory kit items (checked state persisted in SwiftData per user)
    @Published var mandatoryKit: [ChecklistItem] = []
    /// User-added custom items (stored & synced with backend)
    @Published var customKit: [ChecklistItem] = []

    @Published var riskProfiles: [RiskProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOffline: Bool = false
    @Published var pendingCount: Int = 0

    private let repository: PreparednessRepositoryProtocol
    private let storage = LocalStorageService.shared
    private let queue = PendingChecklistQueue.shared
    private let networkMonitor = NetworkMonitor.shared
    private let context = SharedModelContainer.shared.context

    private let customCacheKey = "safepath.custom_kit_cache"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Hardcoded mandatory items (stable IDs so SwiftData can track them)

    static let mandatoryItems: [ChecklistItem] = [
        ChecklistItem(id: "mandatory-001", name: "First Aid Kit",          isChecked: false, category: .firstAid,      quantity: 1, priority: .high,   disasterType: "All"),
        ChecklistItem(id: "mandatory-002", name: "Water (3L/person/day)",  isChecked: false, category: .water,         quantity: 3, priority: .high,   disasterType: "All"),
        ChecklistItem(id: "mandatory-003", name: "Flashlight & Batteries", isChecked: false, category: .lighting,      quantity: 1, priority: .medium, disasterType: "All"),
        ChecklistItem(id: "mandatory-004", name: "Emergency Food (3 days)",isChecked: false, category: .food,          quantity: 3, priority: .high,   disasterType: "All"),
        ChecklistItem(id: "mandatory-005", name: "Whistle",                isChecked: false, category: .communication, quantity: 1, priority: .medium, disasterType: "All"),
        ChecklistItem(id: "mandatory-006", name: "Copies of Documents",    isChecked: false, category: .documents,     quantity: 1, priority: .medium, disasterType: "All"),
        ChecklistItem(id: "mandatory-007", name: "Emergency Blanket",      isChecked: false, category: .clothing,      quantity: 2, priority: .medium, disasterType: "All"),
        ChecklistItem(id: "mandatory-008", name: "N95 Mask",               isChecked: false, category: .hygiene,       quantity: 5, priority: .high,   disasterType: "All"),
        ChecklistItem(id: "mandatory-009", name: "Power Bank",             isChecked: false, category: .communication, quantity: 1, priority: .medium, disasterType: "All"),
        ChecklistItem(id: "mandatory-010", name: "Cash (small bills)",     isChecked: false, category: .documents,     quantity: 1, priority: .medium, disasterType: "All"),
    ]

    // MARK: - Init

    init(repository: PreparednessRepositoryProtocol? = nil) {
        self.repository = repository ?? PreparednessRepository()
        observeNetwork()
    }

    // MARK: - Network Observer

    private func observeNetwork() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { [weak self] connected in
                guard let self else { return }
                self.isOffline = !connected
                if connected {
                    Task {
                        await self.flushPendingOperations()
                        await self.loadCustomItems()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Load

    func load(lat: Double, lng: Double) async {
        isLoading = true
        defer { isLoading = false }
        await loadCustomItems()
        await loadRiskProfiles(lat: lat, lng: lng)
    }

    /// Call this after userVM is available (pass real userID so state is per-user)
    func loadMandatoryItems(userId: String?) {
        guard let userId else {
            mandatoryKit = Self.mandatoryItems
            return
        }

        var items = Self.mandatoryItems
        // Fetch all saved checked states for this user from SwiftData
        let descriptor = FetchDescriptor<SDEmergencyKitItem>(
            predicate: #Predicate { $0.userId == userId }
        )
        let saved = (try? context.fetch(descriptor)) ?? []
        let checkedMap = Dictionary(uniqueKeysWithValues: saved.map { ($0.itemId, $0.isChecked) })

        // Apply persisted checked state
        for i in items.indices {
            items[i].isChecked = checkedMap[items[i].id] ?? false
        }
        mandatoryKit = items
    }

    // MARK: - Toggle mandatory item (SwiftData)

    func toggleMandatoryItem(_ item: ChecklistItem, userId: String) {
        guard let index = mandatoryKit.firstIndex(where: { $0.id == item.id }) else { return }
        mandatoryKit[index].isChecked.toggle()
        let newChecked = mandatoryKit[index].isChecked

        // Upsert in SwiftData
        let compositeKey = "\(userId)_\(item.id)"
        let descriptor = FetchDescriptor<SDEmergencyKitItem>(
            predicate: #Predicate { $0.compositeKey == compositeKey }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.isChecked = newChecked
            existing.updatedAt = Date()
        } else {
            let newRecord = SDEmergencyKitItem(itemId: item.id, userId: userId, isChecked: newChecked)
            context.insert(newRecord)
        }
        try? context.save()
    }

    // MARK: - Custom Items (API-backed)

    func loadCustomItems() async {
        guard networkMonitor.isConnected else {
            if let cached: [ChecklistItem] = storage.load(forKey: customCacheKey) {
                customKit = cached
            }
            isOffline = true
            return
        }

        do {
            let items = try await repository.getAllItem()
            customKit = items
            storage.save(items, forKey: customCacheKey)
            isOffline = false
        } catch {
            if let cached: [ChecklistItem] = storage.load(forKey: customCacheKey), !cached.isEmpty {
                customKit = cached
            }
        }
        pendingCount = queue.pendingCount()
    }

    /// Combined list for backward compatibility (mandatory first, then custom)
    var emergencyKit: [ChecklistItem] {
        mandatoryKit + customKit
    }

    /// Toggle a custom (API-backed) item
    func toggleItem(_ item: ChecklistItem) async {
        guard let index = customKit.firstIndex(where: { $0.id == item.id }) else { return }
        customKit[index].isChecked.toggle()
        let updatedItem = customKit[index]
        storage.save(customKit, forKey: customCacheKey)

        if networkMonitor.isConnected {
            do {
                let saved = try await repository.updateItem(updatedItem)
                customKit[index] = saved
                storage.save(customKit, forKey: customCacheKey)
            } catch {
                customKit[index].isChecked = item.isChecked
                storage.save(customKit, forKey: customCacheKey)
                queueOperation(type: .toggle, item: updatedItem)
                errorMessage = "Offline: perubahan disimpan dan akan dikirim saat online."
            }
        } else {
            queueOperation(type: .toggle, item: updatedItem)
            errorMessage = "Offline: perubahan disimpan dan akan dikirim saat online."
        }
        pendingCount = queue.pendingCount()
    }

    /// Edit a custom item (API-backed)
    func editItem(_ item: ChecklistItem) async {
        guard let index = customKit.firstIndex(where: { $0.id == item.id }) else { return }
        let originalItem = customKit[index]
        customKit[index] = item
        storage.save(customKit, forKey: customCacheKey)

        if networkMonitor.isConnected {
            do {
                let saved = try await repository.updateItem(item)
                customKit[index] = saved
                storage.save(customKit, forKey: customCacheKey)
            } catch {
                customKit[index] = originalItem
                storage.save(customKit, forKey: customCacheKey)
                queueOperation(type: .toggle, item: item) // Using .toggle since the queue just calls updateItem for it
                errorMessage = "Offline: perubahan disimpan dan akan dikirim saat online."
            }
        } else {
            queueOperation(type: .toggle, item: item)
            errorMessage = "Offline: perubahan disimpan dan akan dikirim saat online."
        }
        pendingCount = queue.pendingCount()
    }

    /// Add a custom item (API-backed)
    func addItem(_ item: ChecklistItem) async {
        if networkMonitor.isConnected {
            do {
                let saved = try await repository.createItem(item)
                customKit.insert(saved, at: 0)
                storage.save(customKit, forKey: customCacheKey)
            } catch {
                customKit.insert(item, at: 0)
                storage.save(customKit, forKey: customCacheKey)
                queueOperation(type: .create, item: item)
                errorMessage = "Offline: item disimpan dan akan dikirim saat online."
            }
        } else {
            customKit.insert(item, at: 0)
            storage.save(customKit, forKey: customCacheKey)
            queueOperation(type: .create, item: item)
            errorMessage = "Offline: item disimpan dan akan dikirim saat online."
        }
        pendingCount = queue.pendingCount()
    }

    /// Delete a custom item
    func deleteItem(id: String) async {
        guard let item = customKit.first(where: { $0.id == id }) else { return }
        customKit.removeAll { $0.id == id }
        storage.save(customKit, forKey: customCacheKey)

        if networkMonitor.isConnected {
            do {
                try await repository.deleteItem(id: id)
            } catch {
                customKit.insert(item, at: 0)
                storage.save(customKit, forKey: customCacheKey)
                queueOperation(type: .delete, item: item)
                errorMessage = "Offline: penghapusan akan dikirim saat online."
            }
        } else {
            queueOperation(type: .delete, item: item)
        }
        pendingCount = queue.pendingCount()
    }

    // MARK: - Risk Profiles

    func loadRiskProfiles(lat: Double, lng: Double) async {
        do {
            let profiles = try await repository.fetchRiskProfiles(lat: lat, lng: lng)
            self.riskProfiles = profiles
        } catch {
            self.riskProfiles = Self.mockRiskProfiles
        }
    }

    // MARK: - Offline Queue

    func flushPendingOperations() async {
        guard networkMonitor.isConnected else { return }
        await queue.flush(using: repository)
        pendingCount = queue.pendingCount()
    }

    private func queueOperation(type: PendingOperationType, item: ChecklistItem) {
        let op = PendingChecklistOperation(id: UUID().uuidString, type: type, item: item, queuedAt: Date())
        queue.enqueue(op)
    }

    // MARK: - Computed

    var overallReadiness: Double {
        let all = emergencyKit
        guard !all.isEmpty else { return 0 }
        return Double(all.filter { $0.isChecked }.count) / Double(all.count)
    }

    var completedItemsCount: Int { emergencyKit.filter { $0.isChecked }.count }
    var totalItemsCount: Int     { emergencyKit.count }

    var kitCategory: [KitCategory: [ChecklistItem]] {
        Dictionary(grouping: emergencyKit, by: { $0.category })
    }

    // MARK: - Mock Risk Profiles

    private static let mockRiskProfiles: [RiskProfile] = [
        RiskProfile(id: "1", type: "Earthquake", iconName: "waveform.path.ecg",    level: .high),
        RiskProfile(id: "2", type: "Flood",      iconName: "cloud.heavyrain.fill",  level: .medium),
        RiskProfile(id: "3", type: "Tsunami",    iconName: "water.waves",           level: .low),
    ]
}
