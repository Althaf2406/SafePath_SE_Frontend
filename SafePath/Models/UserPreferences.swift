import Foundation

/// Represents the user's settings/preferences stored as JSONB in the backend.
struct UserPreferences: Codable, Equatable {
    var notificationsOn: Bool
    var disasterAlerts: Bool
    var familyStatus: Bool
    var sosAlerts: Bool
    var prepReminders: Bool
    var selectedThreshold: Int // 0: Critical, 1: Medium+, 2: All
    var liveMonitoring: Bool
    var locationSharingMode: String // "realtime", "emergency", "offline_only"
    var familyPrivacyOn: Bool

    enum CodingKeys: String, CodingKey {
        case notificationsOn = "notifications_on"
        case disasterAlerts = "disaster_alerts"
        case familyStatus = "family_status"
        case sosAlerts = "sos_alerts"
        case prepReminders = "prep_reminders"
        case selectedThreshold = "selected_threshold"
        case liveMonitoring = "live_monitoring"
        case locationSharingMode = "location_sharing_mode"
        case familyPrivacyOn = "family_privacy_on"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationsOn = try container.decodeIfPresent(Bool.self, forKey: .notificationsOn) ?? true
        self.disasterAlerts = try container.decodeIfPresent(Bool.self, forKey: .disasterAlerts) ?? true
        self.familyStatus = try container.decodeIfPresent(Bool.self, forKey: .familyStatus) ?? true
        self.sosAlerts = try container.decodeIfPresent(Bool.self, forKey: .sosAlerts) ?? true
        self.prepReminders = try container.decodeIfPresent(Bool.self, forKey: .prepReminders) ?? false
        self.selectedThreshold = try container.decodeIfPresent(Int.self, forKey: .selectedThreshold) ?? 1
        self.liveMonitoring = try container.decodeIfPresent(Bool.self, forKey: .liveMonitoring) ?? true
        self.locationSharingMode = try container.decodeIfPresent(String.self, forKey: .locationSharingMode) ?? "realtime"
        self.familyPrivacyOn = try container.decodeIfPresent(Bool.self, forKey: .familyPrivacyOn) ?? true
    }

    /// Default initialization for new users or empty JSON.
    init(
        notificationsOn: Bool = true,
        disasterAlerts: Bool = true,
        familyStatus: Bool = true,
        sosAlerts: Bool = true,
        prepReminders: Bool = false,
        selectedThreshold: Int = 1,
        liveMonitoring: Bool = true,
        locationSharingMode: String = "realtime",
        familyPrivacyOn: Bool = true
    ) {
        self.notificationsOn = notificationsOn
        self.disasterAlerts = disasterAlerts
        self.familyStatus = familyStatus
        self.sosAlerts = sosAlerts
        self.prepReminders = prepReminders
        self.selectedThreshold = selectedThreshold
        self.liveMonitoring = liveMonitoring
        self.locationSharingMode = locationSharingMode
        self.familyPrivacyOn = familyPrivacyOn
    }
}
