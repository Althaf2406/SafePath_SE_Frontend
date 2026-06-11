import Foundation
import Combine

/// Person 3: A disaster-specific checklist template.
struct DisasterChecklist: Codable, Identifiable {
    let id: String
    var disasterType: String  // "earthquake", "flood", "tsunami", "fire"
    var title: String
    var items: [ChecklistItem]
    
    // TODO: Person 3 — Add difficulty level, estimated prep time, priority order.
}
