import Foundation

/// Represents a disaster preparation guide.
struct DisasterPreparationGuide: Codable, Identifiable {
    let id: String
    var disasterType: String // e.g., "Flood", "Earthquake", "Tsunami"
    var title: String
    var description: String
    var handlingProcedures: [String]
    var iconName: String
}
