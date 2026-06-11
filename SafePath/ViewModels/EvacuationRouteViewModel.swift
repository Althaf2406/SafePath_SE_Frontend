import Foundation
import MapKit
import CoreLocation
import Combine

/// Manages evacuation route calculation using MapKit directions.
@MainActor
final class EvacuationRouteViewModel: ObservableObject {
    
    @Published var currentRoute: EvacuationRoute?
    @Published var alternativeRoutes: [EvacuationRoute] = []
    @Published var isCalculating = false
    @Published var routeError: String?
    
    private let routeRepository: RouteRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Integration hooks for Person 2
    var onShareRoute: ((EvacuationRoute) -> Void)?
    var onSOS: (() -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveRouteOffline: ((EvacuationRoute) -> Void)?
    
    init(routeRepository: RouteRepositoryProtocol) {
        self.routeRepository = routeRepository
    }
    
    convenience init() {
        self.init(routeRepository: RouteRepository())
    }
    
    // MARK: - Route Calculation
    
    /// Calculate route from user location to selected shelter.
    func calculateRoute(from origin: CLLocationCoordinate2D, to shelter: Shelter) async {
        isCalculating = true
        routeError = nil
        
        do {
            let (primary, alternatives) = try await routeRepository.calculateRouteWithAlternatives(
                from: origin,
                to: shelter
            )
            currentRoute = primary
            alternativeRoutes = alternatives
            
            // Sync with Apple Watch
            sendRouteSummaryToWatch()
        } catch {
            routeError = error.localizedDescription
            currentRoute = nil
            alternativeRoutes = []
        }
        
        isCalculating = false
    }
    
    /// Recalculate route when user location changes.
    func recalculateIfNeeded(newLocation: CLLocationCoordinate2D, shelter: Shelter) async {
        // Only recalculate if we already have a route and location changed significantly (>100m)
        if let currentRoute = currentRoute, let mkRoute = currentRoute.mkRoute {
            let currentStart = mkRoute.polyline.coordinate
            let distance = newLocation.distanceKm(to: currentStart)
            if distance < 0.1 { return } // Less than 100m, skip
        }
        
        await calculateRoute(from: newLocation, to: shelter)
    }
    
    /// Clear current route.
    func clearRoute() {
        currentRoute = nil
        alternativeRoutes = []
        routeError = nil
    }
    
    // MARK: - Route Selection
    
    /// Switch to an alternative route without recalculating from MapKit.
    func selectRoute(at index: Int) {
        guard index >= 0 && index < alternativeRoutes.count else { return }
        guard let current = currentRoute else { return }
        
        let selectedAlternative = alternativeRoutes[index]
        
        // Swap current and selected alternative
        var newAlternatives = alternativeRoutes
        newAlternatives[index] = current
        
        currentRoute = selectedAlternative
        alternativeRoutes = newAlternatives
        
        // Sync with Apple Watch
        sendRouteSummaryToWatch()
    }
    
    // MARK: - Route Display Helpers
    
    var routeETA: String {
        currentRoute?.etaDisplay ?? "--"
    }
    
    var routeDistance: String {
        currentRoute?.distanceDisplay ?? "--"
    }
    
    var routeSafetyScore: String {
        guard let score = currentRoute?.safetyScore else { return "--" }
        return "\(Int(score * 100))%"
    }
    
    var hasRoute: Bool {
        currentRoute != nil
    }
    
    // MARK: - WatchConnectivity
    
    func sendRouteSummaryToWatch() {
        guard let route = currentRoute else { return }
        
        let payload: [String: Any] = [
            WCPayloadKeys.messageType.rawValue: WCMessageType.routeSummary.rawValue,
            WCPayloadKeys.routeDestination.rawValue: route.shelterName,
            WCPayloadKeys.routeETA.rawValue: route.etaDisplay,
            WCPayloadKeys.routeDistance.rawValue: route.distanceDisplay
        ]
        
        IOSConnectivityManager.shared.sendToWatch(payload: payload)
    }
}
