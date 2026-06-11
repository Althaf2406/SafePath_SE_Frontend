import Foundation

/// Person 2: Represents a notification sent to family members.
struct FamilyNotification: Codable, Identifiable {
    let id: String
    var title: String
    var body: String
    var type: NotificationType
    var timestamp: Date?
    var isRead: Bool

    // Person 2 — Sender info, deep link, and priority
    var senderID: String?
    var senderName: String?
    var priority: NotificationPriority
    var deepLinkAction: DeepLinkAction?
    var relatedEntityID: String?   // ID of related SOS, group, or status

    // MARK: - Nested Types

    enum NotificationType: String, Codable {
        case alert        = "alert"
        case sos          = "sos"
        case statusUpdate = "status_update"
        case routeShared  = "route_shared"
        case familyInvite = "family_invite"
        case memberJoined = "member_joined"
        case prepGuide    = "prep_guide"

        var systemImageName: String {
            switch self {
            case .alert:        return "exclamationmark.triangle.fill"
            case .sos:          return "sos.circle.fill"
            case .statusUpdate: return "checkmark.shield.fill"
            case .routeShared:  return "map.fill"
            case .familyInvite: return "person.badge.plus"
            case .memberJoined: return "person.fill.checkmark"
            case .prepGuide:    return "book.fill"
            }
        }
    }

    enum NotificationPriority: String, Codable {
        case low    = "low"
        case normal = "normal"
        case high   = "high"
        case urgent = "urgent"

        /// Returns true for priority levels that should bypass Do Not Disturb.
        var bypassDND: Bool {
            self == .urgent || self == .high
        }
    }

    enum DeepLinkAction: String, Codable {
        case openMap           = "open_map"
        case openFamilyGroup   = "open_family_group"
        case openEmergencyStatus = "open_emergency_status"
        case openChecklist     = "open_checklist"
        case openPrepGuide     = "open_prep_guide"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case type
        case timestamp
        case isRead           = "is_read"
        case senderID         = "sender_id"
        case senderName       = "sender_name"
        case priority
        case deepLinkAction   = "deep_link_action"
        case relatedEntityID  = "related_entity_id"
    }

    // MARK: - Helpers

    /// Returns true when this notification needs a prominent alert (SOS or urgent).
    var requiresProminentAlert: Bool {
        type == .sos || priority == .urgent
    }

    /// Returns a relative time string for display (e.g. "5 minutes ago").
    var timeAgoDescription: String {
        guard let date = timestamp else { return "" }
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case 0..<60:
            return "Recently"
        case 60..<3600:
            let mins = seconds / 60
            return "\(mins) minute\(mins == 1 ? "" : "s") ago"
        case 3600..<86400:
            let hrs = seconds / 3600
            return "\(hrs) hour\(hrs == 1 ? "" : "s") ago"
        default:
            let days = seconds / 86400
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        type: NotificationType,
        timestamp: Date? = Date(),
        isRead: Bool = false,
        senderID: String? = nil,
        senderName: String? = nil,
        priority: NotificationPriority = .normal,
        deepLinkAction: DeepLinkAction? = nil,
        relatedEntityID: String? = nil
    ) {
        self.id              = id
        self.title           = title
        self.body            = body
        self.type            = type
        self.timestamp       = timestamp
        self.isRead          = isRead
        self.senderID        = senderID
        self.senderName      = senderName
        self.priority        = priority
        self.deepLinkAction  = deepLinkAction
        self.relatedEntityID = relatedEntityID
    }
}
