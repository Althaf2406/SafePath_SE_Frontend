import Foundation

/// Person 2: Represents emergency status for a user.
struct EmergencyStatus: Codable, Identifiable {
    let id: String
    var userID: String
    var userName: String?
    var status: EmergencyStatusType
    var message: String?
    var latitude: Double?
    var longitude: Double?
    var updatedAt: Date?

    // Person 2 — SOS details, responder info, escalation
    var isSOS: Bool
    var escalationLevel: EscalationLevel
    var responderID: String?
    var responderName: String?
    var resolvedAt: Date?

    // MARK: - Nested Types

    enum EmergencyStatusType: String, Codable {
        case safe       = "safe"
        case needHelp   = "need_help"
        case evacuating = "evacuating"
        case sos        = "sos"
        case unknown    = "unknown"

        var displayName: String {
            switch self {
            case .safe:       return "Safe"
            case .needHelp:   return "Needs Help"
            case .evacuating: return "Evacuating"
            case .sos:        return "SOS — Emergency"
            case .unknown:    return "Unknown"
            }
        }

        var isEmergency: Bool {
            self == .needHelp || self == .sos
        }
    }

    enum EscalationLevel: Int, Codable {
        case none     = 0  // Normal status update
        case low      = 1  // Needs help, non-critical
        case medium   = 2  // Evacuating, situation uncertain
        case high     = 3  // SOS triggered, immediate danger
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID          = "user_id"
        case userName        = "user_name"
        case status
        case message
        case latitude
        case longitude
        case updatedAt       = "updated_at"
        case isSOS           = "is_sos"
        case escalationLevel = "escalation_level"
        case responderID     = "responder_id"
        case responderName   = "responder_name"
        case resolvedAt      = "resolved_at"
    }

    // MARK: - Helpers

    /// Returns true when this status has been resolved by a responder.
    var isResolved: Bool {
        resolvedAt != nil
    }

    /// Returns true when a location is available with this status.
    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }

    /// Returns true when this status requires immediate family notification.
    var requiresImmediateAlert: Bool {
        isSOS || escalationLevel == .high || status == .needHelp
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        userID: String,
        status: EmergencyStatusType = .unknown,
        message: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        updatedAt: Date? = Date(),
        isSOS: Bool = false,
        escalationLevel: EscalationLevel = .none,
        responderID: String? = nil,
        responderName: String? = nil,
        resolvedAt: Date? = nil
    ) {
        self.id              = id
        self.userID          = userID
        self.status          = status
        self.message         = message
        self.latitude        = latitude
        self.longitude       = longitude
        self.updatedAt       = updatedAt
        self.isSOS           = isSOS
        self.escalationLevel = escalationLevel
        self.responderID     = responderID
        self.responderName   = responderName
        self.resolvedAt      = resolvedAt
    }
}
