import Foundation
import Combine

protocol ChecklistRepositoryProtocol {
    func fetchCustomItems() -> AnyPublisher<[ChecklistItem], Error>
    func fetchItems(forDisasterType disasterType: String) -> AnyPublisher<[ChecklistItem], Error>
    func saveCustomItem(_ item: ChecklistItem) -> AnyPublisher<Void, Error>
    func deleteCustomItem(id: String) -> AnyPublisher<Void, Error>
}

/// Person 3: Repository for checklist data persistence.
final class ChecklistRepository: ChecklistRepositoryProtocol {
    
    // Simulating local storage with an in-memory array for now.
    private var customItems: [ChecklistItem] = [
        ChecklistItem(id: UUID().uuidString, name: "First Aid Kit", isChecked: false, category: .firstAid, quantity: 1, priority: .high, disasterType: "All"),
        ChecklistItem(id: UUID().uuidString, name: "Water Purifier", isChecked: false, category: .water, quantity: 2, priority: .high, disasterType: "Flood"),
        ChecklistItem(id: UUID().uuidString, name: "Life Jacket", isChecked: false, category: .clothing, quantity: 1, priority: .high, disasterType: "Flood"),
        ChecklistItem(id: UUID().uuidString, name: "Whistle", isChecked: false, category: .communication, quantity: 1, priority: .high, disasterType: "Earthquake"),
        ChecklistItem(id: UUID().uuidString, name: "N95 Mask", isChecked: false, category: .hygiene, quantity: 5, priority: .high, disasterType: "Fire")
    ]
    
    func fetchCustomItems() -> AnyPublisher<[ChecklistItem], Error> {
        return Just(customItems)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchItems(forDisasterType disasterType: String) -> AnyPublisher<[ChecklistItem], Error> {
        let filtered = customItems.filter { $0.disasterType == disasterType || $0.disasterType == "All" }
        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveCustomItem(_ item: ChecklistItem) -> AnyPublisher<Void, Error> {
        if let index = customItems.firstIndex(where: { $0.id == item.id }) {
            customItems[index] = item
        } else {
            customItems.insert(item, at: 0)
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteCustomItem(id: String) -> AnyPublisher<Void, Error> {
        customItems.removeAll(where: { $0.id == id })
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
