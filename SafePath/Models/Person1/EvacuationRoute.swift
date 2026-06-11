import Foundation
import Combine
import MapKit

/// Represents a calculated evacuation route from user location to a shelter.
struct EvacuationRoute: Identifiable {
    let id: String
    let shelterId: String
    let shelterName: String
    let distanceMeters: Double
    let expectedTravelTime: TimeInterval
    let safetyScore: Double  // 0.0–1.0 placeholder; future risk layer integration
    let mkRoute: MKRoute?
    let customPolyline: MKPolyline? // Used for offline straight line
    
    /// Polyline for map overlay display.
    var polyline: MKPolyline? {
        customPolyline ?? mkRoute?.polyline
    }
    
    var distanceKm: Double {
        distanceMeters / 1000.0
    }
    
    var etaDisplay: String {
        expectedTravelTime.etaDisplay
    }
    
    var distanceDisplay: String {
        distanceKm.distanceDisplay
    }
}

// MARK: - Preview / Test Fixture

#if DEBUG
extension EvacuationRoute {
    static let preview = EvacuationRoute(
        id: "preview-route-1",
        shelterId: "preview-shelter-1",
        shelterName: "GOR Bung Tomo Surabaya",
        distanceMeters: 1800,
        expectedTravelTime: 420,
        safetyScore: 0.85,
        mkRoute: nil,
        customPolyline: nil
    )
}
#endif
