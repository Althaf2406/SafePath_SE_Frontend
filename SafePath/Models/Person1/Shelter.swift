import Foundation
import Combine
import CoreLocation

/// Shelter status indicating availability.
enum ShelterStatus: String, Codable, CaseIterable {
    case available    = "available"
    case almostFull   = "almost_full"
    case full         = "full"
    case closed       = "closed"
    case unsafe       = "unsafe"
    
    var displayName: String {
        switch self {
        case .available:  return "Available"
        case .almostFull: return "Almost Full"
        case .full:       return "Full"
        case .closed:     return "Closed"
        case .unsafe:     return "Unsafe"
        }
    }
    
    /// Whether this shelter can accept evacuees.
    var isAccepting: Bool {
        self == .available || self == .almostFull
    }
}

/// Shelter type enum
enum ShelterType: String, Codable {
    case building = "building"
    case openArea = "open_area"
    case verticalShelter = "vertical_shelter"
    
    var displayName: String {
        switch self {
        case .building: return "Indoor Building"
        case .openArea: return "Open Area field"
        case .verticalShelter: return "Vertical Shelter"
        }
    }
}

/// A shelter/evacuation point fetched from the SafePath backend (PostgreSQL).
struct Shelter: Codable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let capacity: Int
    let availableCapacity: Int?
    let contact: String?
    let facilities: [String]
    let shelterType: ShelterType
    let disasterTypeSupported: [String]
    let isOpenArea: Bool
    let buildingLevel: Int
    let isActive: Bool
    
    // Populated by nearby/recommendation endpoint or client-side calculation
    var distanceKm: Double?
    var recommendationScore: Int?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var status: ShelterStatus {
        isActive ? .available : .closed
    }
    
    var availableSpace: Int {
        capacity
    }
    
    /// Returns a human-readable facility name from the facility key.
    static func facilityDisplayName(_ key: String) -> String {
        switch key.lowercased() {
        case "water", "air bersih": return "Water"
        case "food", "makanan":     return "Food"
        case "medical", "medis":    return "Medical"
        case "toilet":              return "Toilet"
        case "charging", "listrik": return "Power Charging"
        case "sleeping_area":       return "Sleeping Area"
        default:                    return key.capitalized
        }
    }
    
    /// Returns an SF Symbol name for the facility key.
    static func facilityIcon(_ key: String) -> String {
        switch key.lowercased() {
        case "water", "air bersih": return "drop.fill"
        case "food", "makanan":     return "fork.knife"
        case "medical", "medis":    return "cross.case.fill"
        case "toilet":              return "toilet.fill"
        case "charging", "listrik": return "bolt.fill"
        case "sleeping_area":       return "bed.double.fill"
        default:                    return "building.2.fill"
        }
    }
}


// MARK: - Preview / Test Fixture

#if DEBUG
extension Shelter {
    static let preview = Shelter(
        id: 1,
        name: "GOR Bung Tomo Surabaya",
        address: "Jl. Joyoboyo No.1, Sawunggaling, Wonokromo, Surabaya",
        latitude: -7.3071,
        longitude: 112.7358,
        capacity: 1200,
        availableCapacity: 1100,
        contact: "081234567891",
        facilities: ["water", "food", "toilet", "sleeping_area"],
        shelterType: .openArea,
        disasterTypeSupported: ["earthquake"],
        isOpenArea: true,
        buildingLevel: 1,
        isActive: true,
        distanceKm: 1.8,
        recommendationScore: 0
    )
    
    static let previewAlmostFull = Shelter(
        id: 2,
        name: "Balai Pemuda Surabaya",
        address: "Jl. Gubernur Suryo No.15, Genteng, Surabaya",
        latitude: -7.2619,
        longitude: 112.7487,
        capacity: 500,
        availableCapacity: 50,
        contact: "081234567892",
        facilities: ["water", "toilet", "charging"],
        shelterType: .building,
        disasterTypeSupported: ["flood"],
        isOpenArea: false,
        buildingLevel: 2,
        isActive: true,
        distanceKm: 3.2,
        recommendationScore: 0
    )
    
    static let previewList: [Shelter] = [preview, previewAlmostFull]
}
#endif
