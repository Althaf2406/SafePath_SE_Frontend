import Foundation
import Combine
import CoreLocation
import UserNotifications

/// View state for data-driven UI.
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)
}

/// Manages disaster alert data and local notification scheduling.
@MainActor
final class DisasterAlertViewModel: ObservableObject {
    
    @Published var allAlerts: [DisasterAlert] = []
    @Published var nearbyAlerts: [DisasterAlert] = []
    @Published var state: ViewState<[DisasterAlert]> = .idle
    @Published var selectedAlert: DisasterAlert?
    
    private let repository: DisasterAlertRepositoryProtocol
    
    // MARK: - Integration hooks for Person 2
    var onNotifyFamily: ((DisasterAlert) -> Void)?
    var onMarkSafe: (() -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveAlertOffline: ((DisasterAlert) -> Void)?
    
    init(repository: DisasterAlertRepositoryProtocol) {
        self.repository = repository
    }
    
    convenience init() {
        self.init(repository: DisasterAlertRepository())
    }
    
    // MARK: - Fetch All Alerts
    
    func fetchAllAlerts() async {
        state = .loading
        do {
            let alerts = try await repository.fetchAllAlerts()
            allAlerts = alerts
            state = alerts.isEmpty ? .empty : .loaded(alerts)
        } catch {
            print("⚠️ API DisasterAlerts Gagal: \(error.localizedDescription). Beralih ke data mock.")
            let mockAlerts = [DisasterAlert.previewCritical, DisasterAlert.preview]
            self.allAlerts = mockAlerts
            self.state = .loaded(mockAlerts)
        }
    }
    
    // MARK: - Fetch Nearby Alerts
    
    func fetchNearbyAlerts(location: CLLocationCoordinate2D) async {
        await fetchNearbyAlerts(location: location, radiusKm: AppConstants.alertProximityThresholdKm)
    }
    
    func fetchNearbyAlerts(location: CLLocationCoordinate2D, radiusKm: Double) async {
        do {
            let alerts = try await repository.fetchNearbyAlerts(
                lat: location.latitude,
                lng: location.longitude,
                radiusKm: radiusKm
            )
            nearbyAlerts = alerts
            
            // Sync with Apple Watch
            sendLatestAlertToWatch()
            
            // Schedule local notifications for high-severity nearby alerts
            for alert in alerts where alert.severity == .critical || alert.severity == .high {
                scheduleLocalNotification(for: alert)
            }
        } catch {
            print("⚠️ Failed to fetch nearby alerts: \(error.localizedDescription). Beralih ke data mock.")
            let allMocks = [DisasterAlert.preview, DisasterAlert.previewCritical]
            let filtered = allMocks.compactMap { alert -> DisasterAlert? in
                let alertLoc = CLLocation(latitude: alert.latitude, longitude: alert.longitude)
                let userLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let distance = alertLoc.distance(from: userLoc) / 1000.0
                if distance <= radiusKm {
                    var updated = alert
                    updated.distanceKm = distance
                    return updated
                }
                return nil
            }
            self.nearbyAlerts = filtered
            
            // Schedule local notifications for mock high-severity nearby alerts
            for alert in filtered where alert.severity == .critical || alert.severity == .high {
                scheduleLocalNotification(for: alert)
            }
        }
    }
    
    // MARK: - Local Notification
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleLocalNotification(for alert: DisasterAlert) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ \(alert.typeDisplayName) — \(alert.severity.displayName)"
        content.body = "\(alert.locationName). Magnitudo \(alert.magnitude). \(alert.instruction)"
        content.sound = .default
        content.categoryIdentifier = "DISASTER_ALERT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "disaster-\(alert.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Filtered views
    
    var criticalAlerts: [DisasterAlert] {
        allAlerts.filter { $0.severity == .critical }
    }
    
    var highSeverityAlerts: [DisasterAlert] {
        allAlerts.filter { $0.severity == .critical || $0.severity == .high }
    }
    
    // MARK: - WatchConnectivity
    
    func sendLatestAlertToWatch() {
        guard let latest = allAlerts.first ?? nearbyAlerts.first else { return }
        
        let payload: [String: Any] = [
            WCPayloadKeys.messageType.rawValue: WCMessageType.newAlert.rawValue,
            WCPayloadKeys.alertType.rawValue: latest.typeDisplayName,
            WCPayloadKeys.alertSeverity.rawValue: latest.severity.displayName,
            WCPayloadKeys.alertLocation.rawValue: latest.locationName,
            WCPayloadKeys.alertTimestamp.rawValue: Date().timeIntervalSince1970
        ]
        
        IOSConnectivityManager.shared.sendToWatch(payload: payload)
    }
}
