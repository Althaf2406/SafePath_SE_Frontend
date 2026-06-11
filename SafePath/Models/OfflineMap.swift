import Foundation
import Combine

/// Person 3: Represents an offline map region.
struct OfflineMap: Codable, Identifiable {
    let id: String
    var regionName: String
    var centerLatitude: Double
    var centerLongitude: Double
    var radiusKm: Double
    var downloadedAt: Date?
    var sizeBytes: Int64?
    
    // TODO: Person 3 — Add map tile storage path, zoom levels, expiry date.
}
