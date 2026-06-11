import Foundation
import Combine

protocol PreparednessRepositoryProtocol {
    func getAllItem() async throws -> [ChecklistItem]
    func createItem(_ item: ChecklistItem) async throws -> ChecklistItem
    func updateItem(_ item: ChecklistItem) async throws -> ChecklistItem
    func deleteItem(id: String) async throws
    func fetchRiskProfiles(lat: Double, lng: Double) async throws -> [RiskProfile]
}

/// Person 3: Repository for preparedness data persistence.
final class PreparednessRepository: PreparednessRepositoryProtocol {

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    // MARK: - Emergency Kit CRUD

    /// Fetch all emergency kit items for this user.
    func getAllItem() async throws -> [ChecklistItem] {
        return try await api.fetchData(.getAllItem)
    }

    /// Create a new emergency kit item.
    func createItem(_ item: ChecklistItem) async throws -> ChecklistItem {
        let body: [String: Any] = [
            "id":          item.id,
            "name":        item.name,
            "isChecked":   item.isChecked,
            "category":    item.category.rawValue,
            "quantity":    item.quantity as Any,
            "priority":    item.priority.rawValue,
            "disasterType": item.disasterType as Any
        ]
        let wrapper: APIResponse<ChecklistItem> = try await api.send(.createItem, body: body)
        return wrapper.data
    }

    /// Update (toggle checked state) of an existing item.
    func updateItem(_ item: ChecklistItem) async throws -> ChecklistItem {
        let body: [String: Any] = [
            "name":        item.name,
            "isChecked":   item.isChecked,
            "category":    item.category.rawValue,
            "quantity":    item.quantity as Any,
            "priority":    item.priority.rawValue,
            "disasterType": item.disasterType as Any
        ]
        let wrapper: APIResponse<ChecklistItem> = try await api.send(.updateItem(id: item.id), body: body)
        return wrapper.data
    }

    /// Delete a kit item by ID.
    func deleteItem(id: String) async throws {
        try await api.sendVoid(.deleteItem(id: id))
    }

    // MARK: - Risk Profiles

    /// Fetch local risk profiles from backend.
    func fetchRiskProfiles(lat: Double, lng: Double) async throws -> [RiskProfile] {
        return try await api.fetchData(.riskProfiles(lat: lat, lng: lng))
    }
}
