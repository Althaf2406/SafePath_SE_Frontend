import Foundation

/// Person 3: Represents an item needed for a first aid procedure.
struct FirstAidKitItem: Codable, Identifiable {
    let id: String
    var name: String
    var status: KitItemStatus
    
    enum KitItemStatus: String, Codable {
        case inKit = "In Kit"
        case missing = "Missing"
    }
}
