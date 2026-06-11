import Foundation
import Combine

/// Person 2: Represents a family group for emergency coordination.
struct FamilyGroup: Codable, Identifiable {
    let id: String
    var name: String
    var members: [FamilyMember]
    var createdAt: Date?

    // Person 2 — Invite code, admin, and group settings
    var inviteCode: String
    var adminUserID: String
    var maxMembers: Int
    var isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
        case createdAt    = "created_at"
        case inviteCode   = "invite_code"
        case adminUserID  = "admin_user_id"
        case maxMembers   = "max_members"
        case isActive     = "is_active"
    }

    // MARK: - Helpers

    /// Returns the admin member object if found among members.
    var admin: FamilyMember? {
        members.first { $0.id == adminUserID }
    }

    /// Returns only members who are currently marked safe.
    var safeMembers: [FamilyMember] {
        members.filter { $0.isSafe == true }
    }

    /// Returns members whose safety status is unknown or not yet updated.
    var unknownMembers: [FamilyMember] {
        members.filter { $0.isSafe == nil }
    }

    /// Returns true when the group still has room for more members.
    var hasCapacity: Bool {
        members.count < maxMembers
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        members: [FamilyMember] = [],
        createdAt: Date? = Date(),
        inviteCode: String = String(UUID().uuidString.prefix(8).uppercased()),
        adminUserID: String,
        maxMembers: Int = 20,
        isActive: Bool = true
    ) {
        self.id           = id
        self.name         = name
        self.members      = members
        self.createdAt    = createdAt
        self.inviteCode   = inviteCode
        self.adminUserID  = adminUserID
        self.maxMembers   = maxMembers
        self.isActive     = isActive
    }
}
