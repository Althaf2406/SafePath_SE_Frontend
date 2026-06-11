import Foundation
import Combine
import MapKit

protocol RouteRepositoryProtocol {
    func calculateRoute(from origin: CLLocationCoordinate2D, to shelter: Shelter) async throws -> EvacuationRoute
    func calculateRouteWithAlternatives(from origin: CLLocationCoordinate2D, to shelter: Shelter) async throws -> (primary: EvacuationRoute, alternatives: [EvacuationRoute])
}

/// Generates real evacuation routes using MapKit MKDirections.
@MainActor
final class RouteRepository: RouteRepositoryProtocol {
    
    /// Calculate a walking route from origin to a shelter coordinate using MapKit.
    func calculateRoute(
        from origin: CLLocationCoordinate2D,
        to shelter: Shelter
    ) async throws -> EvacuationRoute {
        let request = MKDirections.Request()
        let originLoc = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        request.source = MKMapItem(location: originLoc, address: nil)
        let destLoc = CLLocation(latitude: shelter.coordinate.latitude, longitude: shelter.coordinate.longitude)
        request.destination = MKMapItem(location: destLoc, address: nil)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            guard let primaryRoute = response.routes.first else {
                throw RouteError.noRouteFound
            }
            
            return EvacuationRoute(
                id: UUID().uuidString,
                shelterId: String(shelter.id),
                shelterName: shelter.name,
                distanceMeters: primaryRoute.distance,
                expectedTravelTime: primaryRoute.expectedTravelTime,
                safetyScore: 0.85, // Placeholder
                mkRoute: primaryRoute,
                customPolyline: nil
            )
        } catch {
            // Fallback to straight line (offline mode)
            var coordinates = [origin, shelter.coordinate]
            let straightLine = MKPolyline(coordinates: &coordinates, count: 2)
            let distance = originLoc.distance(from: destLoc)
            
            return EvacuationRoute(
                id: UUID().uuidString,
                shelterId: String(shelter.id),
                shelterName: shelter.name,
                distanceMeters: distance,
                expectedTravelTime: distance / 1.4, // Average walking speed 1.4 m/s
                safetyScore: 0.5,
                mkRoute: nil,
                customPolyline: straightLine
            )
        }
    }
    
    /// Calculate route and return alternatives too.
    func calculateRouteWithAlternatives(
        from origin: CLLocationCoordinate2D,
        to shelter: Shelter
    ) async throws -> (primary: EvacuationRoute, alternatives: [EvacuationRoute]) {
        let request = MKDirections.Request()
        let originLoc = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        request.source = MKMapItem(location: originLoc, address: nil)
        let destLoc = CLLocation(latitude: shelter.coordinate.latitude, longitude: shelter.coordinate.longitude)
        request.destination = MKMapItem(location: destLoc, address: nil)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            guard let primaryMK = response.routes.first else {
                throw RouteError.noRouteFound
            }
            
            let primary = EvacuationRoute(
                id: UUID().uuidString,
                shelterId: String(shelter.id),
                shelterName: shelter.name,
                distanceMeters: primaryMK.distance,
                expectedTravelTime: primaryMK.expectedTravelTime,
                safetyScore: 0.85,
                mkRoute: primaryMK,
                customPolyline: nil
            )
            
            let alternatives = response.routes.dropFirst().map { route in
                EvacuationRoute(
                    id: UUID().uuidString,
                    shelterId: String(shelter.id),
                    shelterName: shelter.name,
                    distanceMeters: route.distance,
                    expectedTravelTime: route.expectedTravelTime,
                    safetyScore: 0.75,
                    mkRoute: route,
                    customPolyline: nil
                )
            }
            
            return (primary, Array(alternatives))
        } catch {
            // Fallback to straight line (offline mode)
            var coordinates = [origin, shelter.coordinate]
            let straightLine = MKPolyline(coordinates: &coordinates, count: 2)
            let distance = originLoc.distance(from: destLoc)
            
            let offlinePrimary = EvacuationRoute(
                id: UUID().uuidString,
                shelterId: String(shelter.id),
                shelterName: shelter.name,
                distanceMeters: distance,
                expectedTravelTime: distance / 1.4,
                safetyScore: 0.5,
                mkRoute: nil,
                customPolyline: straightLine
            )
            return (offlinePrimary, [])
        }
    }
}

// MARK: - Route Error

enum RouteError: LocalizedError {
    case noRouteFound
    case calculationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noRouteFound:
            return "No evacuation route found to this shelter."
        case .calculationFailed(let err):
            return "Route calculation failed: \(err.localizedDescription)"
        }
    }
}
