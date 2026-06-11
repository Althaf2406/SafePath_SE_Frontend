import Foundation

/// Person 2: Represents a member in a family group.
struct FamilyMember: Codable, Identifiable {
    let id: String
    var name: String
    var phone: String?
    var isSafe: Bool?
    var lastLatitude: Double?
    var lastLongitude: Double?
    var lastUpdated: Date?

    // Person 2 — Role, status, and avatar
    var role: MemberRole
    var status: MemberStatus
    var avatarURL: String?
    var deviceToken: String?   // For push notifications

    // MARK: - Nested Types

    enum MemberRole: String, Codable {
        case admin  = "admin"
        case member = "member"
    }

    enum MemberStatus: String, Codable {
        case safe       = "safe"
        case needHelp   = "need_help"
        case evacuating = "evacuating"
        case sos        = "sos"
        case unknown    = "unknown"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case isSafe         = "is_safe"
        case lastLatitude   = "last_latitude"
        case lastLongitude  = "last_longitude"
        case lastUpdated    = "last_updated"
        case role
        case status
        case avatarURL      = "avatar_url"
        case deviceToken    = "device_token"
    }

    // MARK: - Helpers

    /// Returns true when this member has a known location.
    var hasLocation: Bool {
        lastLatitude != nil && lastLongitude != nil
    }

    /// Returns true when the member is in an emergency state.
    var isInEmergency: Bool {
        status == .needHelp || status == .sos
    }

    /// Returns a display-friendly string for how long ago the location was updated.
    var lastUpdatedDescription: String {
        guard let date = lastUpdated else { return "Unknown" }
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case 0..<60:    return "Recently"
        case 60..<3600:
            let mins = seconds / 60
            return "\(mins) minute\(mins == 1 ? "" : "s") ago"
        default:
            let hrs = seconds / 3600
            return "\(hrs) hour\(hrs == 1 ? "" : "s") ago"
        }
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        phone: String? = nil,
        isSafe: Bool? = nil,
        lastLatitude: Double? = nil,
        lastLongitude: Double? = nil,
        lastUpdated: Date? = nil,
        role: MemberRole = .member,
        status: MemberStatus = .unknown,
        avatarURL: String? = nil,
        deviceToken: String? = nil
    ) {
        self.id             = id
        self.name           = name
        self.phone          = phone
        self.isSafe         = isSafe
        self.lastLatitude   = lastLatitude
        self.lastLongitude  = lastLongitude
        self.lastUpdated    = lastUpdated
        self.role           = role
        self.status         = status
        self.avatarURL      = avatarURL
        self.deviceToken    = deviceToken
    }
}
