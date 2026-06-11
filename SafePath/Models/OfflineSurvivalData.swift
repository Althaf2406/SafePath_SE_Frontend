import Foundation
import Combine

/// Person 3: Cached data available in offline survival mode.
struct OfflineSurvivalData: Codable, Identifiable {
    let id: String
    var shelters: [String]       // Cached shelter IDs
    var alerts: [String]         // Cached alert IDs
    var routes: [String]         // Cached route descriptions
    var lastSyncedAt: Date?
    
    // TODO: Person 3 — Add cached medical info, emergency contacts, survival tips.
}
