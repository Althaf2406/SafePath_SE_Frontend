import Foundation
import Combine

/// Person 3: Represents a preparedness reminder.
struct PreparednessReminder: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var frequency: String  // "daily", "weekly", "monthly"
    var isCompleted: Bool
    var lastCompletedAt: Date?
    
    // TODO: Person 3 — Add category, priority, notification schedule.
}
