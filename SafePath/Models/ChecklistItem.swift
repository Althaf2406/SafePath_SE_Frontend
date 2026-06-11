import Foundation
import Combine

/// Priority level for checklist items.
enum ChecklistPriority: String, Codable, CaseIterable {
    case high   = "High"
    case medium = "Medium"
    case low    = "Low"
    
    // TODO: Person 3 — Extend with sorting, color mapping, etc.
}
enum KitCategory: String, Codable, CaseIterable {
    case firstAid
    case lighting
    case water
    case food
    case communication
    case navigation
    case clothing
    case tools
    case hygiene
    case documents

    var displayName: String {
        switch self {
        case .firstAid:      return "First Aid"
        case .lighting:      return "Lighting"
        case .water:         return "Water"
        case .food:          return "Food"
        case .communication: return "Communication"
        case .navigation:    return "Navigation"
        case .clothing:      return "Clothing"
        case .tools:         return "Tools"
        case .hygiene:       return "Hygiene"
        case .documents:     return "Documents"
        }
    }
}

/// Person 3: A single item in an emergency checklist.
struct ChecklistItem: Codable, Identifiable {

    let id: String
    var name: String
    var isChecked: Bool
    var category: KitCategory
    var quantity: Int?
    var priority: ChecklistPriority
    var disasterType: String?

}

// MARK: - Preview / Test Fixture

