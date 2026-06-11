import Foundation
import Combine
import CoreLocation

/// Severity level for disaster alerts.
enum AlertSeverity: String, Codable, CaseIterable {
    case critical = "CRITICAL"
    case high     = "HIGH"
    case medium   = "MEDIUM"
    case low      = "LOW"
    
    var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .high:     return "High"
        case .medium:   return "Medium"
        case .low:      return "Low"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .high:     return 1
        case .medium:   return 2
        case .low:      return 3
        }
    }
}

/// A normalized disaster alert from BMKG via the SafePath backend.
struct DisasterAlert: Codable, Identifiable {
    let id: String
    let type: String
    let severity: AlertSeverity
    let magnitude: Double
    let latitude: Double
    let longitude: Double
    let locationName: String
    let instruction: String
    let timestamp: String
    let source: String
    let sourceUrl: String
    let tsunamiPotential: Bool?
    let depth: String?
    let feltDescription: String?
    
    // Populated by nearby endpoint
    var distanceKm: Double?
    var isNearby: Bool?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var parsedDate: Date {
        timestamp.iso8601Date ?? Date()
    }
    
    var typeDisplayName: String {
        switch type {
        case "earthquake_tsunami": return "Gempa & Tsunami"
        case "earthquake":         return "Gempa Bumi"
        default:                   return type.capitalized
        }
    }
}

// MARK: - Preview / Test Fixture

#if DEBUG
extension DisasterAlert {
    static let preview = DisasterAlert(
        id: "preview-1",
        type: "earthquake",
        severity: .high,
        magnitude: 5.2,
        latitude: -7.28,
        longitude: 112.75,
        locationName: "80 km Tenggara Surabaya",
        instruction: "Seek open space immediately.",
        timestamp: "2024-12-01T08:30:00.000Z",
        source: "BMKG",
        sourceUrl: "https://data.bmkg.go.id",
        tsunamiPotential: false,
        depth: "10 km",
        feltDescription: "II-III MMI",
        distanceKm: 82.5,
        isNearby: true
    )
    
    static let previewCritical = DisasterAlert(
        id: "preview-2",
        type: "earthquake_tsunami",
        severity: .critical,
        magnitude: 7.1,
        latitude: -8.20,
        longitude: 115.10,
        locationName: "Selatan Bali",
        instruction: "Move to higher ground immediately. Tsunami warning in effect.",
        timestamp: "2024-12-01T09:00:00.000Z",
        source: "BMKG",
        sourceUrl: "https://data.bmkg.go.id",
        tsunamiPotential: true,
        depth: "28 km",
        feltDescription: nil,
        distanceKm: 350.0,
        isNearby: false
    )
}
#endif
