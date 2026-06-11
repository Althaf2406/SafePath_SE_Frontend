import Foundation

/// Represents the risk level of a local disaster type.
enum RiskLevel: String, Codable, CaseIterable {
    case low      = "Low"
    case medium   = "Medium"
    case high     = "High"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .low:      return SafePathColors.safeGreen
        case .medium:   return SafePathColors.warningOrange
        case .high:     return Color(red: 0.90, green: 0.35, blue: 0.0)
        case .critical: return SafePathColors.dangerRed
        }
    }
}

import SwiftUI

/// Represents a local disaster risk profile entry.
struct RiskProfile: Codable, Identifiable {
    let id: String
    var type: String      // e.g. "Earthquake", "Flood"
    var iconName: String  // SF Symbol name
    var level: RiskLevel
}
