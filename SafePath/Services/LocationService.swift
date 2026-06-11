import Foundation
import CoreLocation
import Combine

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

protocol LocationServiceProtocol: ObservableObject {
    var currentLocation: CLLocationCoordinate2D? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var locationError: String? { get }
    
    func requestPermission()
    func startUpdating()
    func stopUpdating()
    var isAuthorized: Bool { get }
}

/// Manages device location using CoreLocation.
/// Publishes current coordinate and authorization status.
final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50 // Update every 50m
        
        #if targetEnvironment(simulator)
        // Default to Universitas Ciputra Surabaya coordinates for simulator/testing
        self.currentLocation = CLLocationCoordinate2D(latitude: -7.285694, longitude: 112.631611)
        #endif
    }
    
    // MARK: - Public API
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            manager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Please enable in Settings."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if targetEnvironment(simulator)
        // Kunci koordinat ke Universitas Ciputra Surabaya 
        currentLocation = CLLocationCoordinate2D(latitude: -7.285694, longitude: 112.631611)
        #else
        guard let loc = locations.last else { return }
        currentLocation = loc.coordinate
        #endif
        locationError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = "Failed to get location: \(error.localizedDescription)"
    }
}
