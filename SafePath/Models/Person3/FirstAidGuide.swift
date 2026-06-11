import Foundation
import Combine

/// Person 3: Represents a first aid guide topic.
struct FirstAidGuide: Codable, Identifiable {
    let id: String
    var title: String
    var category: String  // "cpr", "bleeding", "burns", "fractures", "choking"
    var shortDescription: String
    var steps: [String] // Keeping for simple overview
    var iconName: String?
    
    // Additional properties for detailed view
    var requiredKit: [FirstAidKitItem] = []
    var detailedSteps: [FirstAidStep] = []
}
