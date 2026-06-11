import Foundation

/// Person 3: Represents a step in a first aid guide.
struct FirstAidStep: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
}
