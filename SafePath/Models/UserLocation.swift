import Foundation
import Combine
import CoreLocation

/// Represents the user's current location snapshot.
struct UserLocation: Codable, Identifiable {
    let id: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = Date()
    }
    
    init(id: String = UUID().uuidString, latitude: Double, longitude: Double, timestamp: Date = Date()) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}

// MARK: - Preview / Test Fixture

#if DEBUG
extension UserLocation {
    /// Surabaya city center
    static let preview = UserLocation(latitude: -7.2575, longitude: 112.7521)
}
#endif
