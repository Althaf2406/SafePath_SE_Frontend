import Foundation
import Combine

protocol DisasterAlertRepositoryProtocol {
    func fetchAllAlerts() async throws -> [DisasterAlert]
    func fetchNearbyAlerts(lat: Double, lng: Double) async throws -> [DisasterAlert]
    func fetchNearbyAlerts(lat: Double, lng: Double, radiusKm: Double) async throws -> [DisasterAlert]
}

@MainActor
final class DisasterAlertRepository: DisasterAlertRepositoryProtocol {
    
    private let api: APIService
    
    @MainActor
    init(api: APIService? = nil) {
        self.api = api ?? APIService.shared
    }
    
    /// Fetch all disaster alerts.
    func fetchAllAlerts() async throws -> [DisasterAlert] {
        return try await api.fetchData(.disasterAlerts)
    }
    
    /// Fetch disaster alerts near a coordinate.
    func fetchNearbyAlerts(lat: Double, lng: Double) async throws -> [DisasterAlert] {
        return try await fetchNearbyAlerts(lat: lat, lng: lng, radiusKm: AppConstants.alertProximityThresholdKm)
    }
    
    func fetchNearbyAlerts(lat: Double, lng: Double, radiusKm: Double) async throws -> [DisasterAlert] {
        return try await api.fetchData(.nearbyAlerts(lat: lat, lng: lng, radiusKm: radiusKm))
    }
}
