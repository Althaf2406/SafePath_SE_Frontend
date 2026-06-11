import Foundation
import SwiftData

/// Person 2: Repository for family group API calls.
/// Connects to Express backend family endpoints via APIService.
final class FamilyRepository: FamilyRepositoryProtocol {

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    // MARK: - Group Endpoints

    /// POST /family/group
    func createGroup(name: String) async throws -> FamilyGroup {
        let body: [String: Any] = ["name": name]
        return try await api.send(.createFamilyGroup, body: body)
    }

    /// POST /family/join
    func joinGroup(inviteCode: String) async throws -> FamilyGroup {
        return try await api.send(.joinFamilyGroup, body: ["invite_code": inviteCode])
    }

    func leaveGroup(groupID: String) async throws {
        try await api.sendVoid(.leaveGroup(groupID: groupID))
    }

    /// GET /family/group/:groupId
    func fetchGroup(groupID: String) async throws -> FamilyGroup {
        return try await api.send(.fetchFamilyGroup(groupID: groupID))
    }

    /// GET /family/groups
    func fetchAllGroups() async throws -> [FamilyGroup] {
        return try await api.send(.fetchAllFamilyGroups)
    }

    // MARK: - Member Endpoints

    /// POST /family/group/:groupId/invite
    func inviteMember(
        groupID: String,
        phone: String? = nil,
        email: String? = nil
    ) async throws -> FamilyMember {
        var body: [String: Any] = [:]
        if let phone = phone { body["phone"] = phone }
        if let email = email { body["email"] = email }

        return try await api.send(.inviteFamilyMember(groupID: groupID), body: body)
    }

    /// DELETE /family/group/:groupId/member/:memberId
    func removeMember(groupID: String, memberID: String) async throws {
        try await api.sendVoid(.removeFamilyMember(groupID: groupID, memberID: memberID))
    }

    /// PUT /family/group/:groupId/member/:memberId/status
    func updateMemberStatus(
        groupID: String,
        memberID: String,
        status: FamilyMember.MemberStatus
    ) async throws -> FamilyMember {
        let body: [String: Any] = ["status": status.rawValue]
        return try await api.send(
            .updateFamilyMemberStatus(groupID: groupID, memberID: memberID),
            body: body
        )
    }

    // MARK: - Location Endpoints

    /// POST /family/location
    func shareLocation(
        groupID: String,
        latitude: Double,
        longitude: Double
    ) async throws {
        let body: [String: Any] = [
            "group_id":  groupID,
            "latitude":  latitude,
            "longitude": longitude
        ]
        try await api.sendVoid(.shareLocation, body: body)
    }

    /// GET /family/group/:groupId/locations
    func fetchFamilyLocations(groupID: String) async throws -> [FamilyMember] {
        let context = SharedModelContainer.shared.context
        do {
            let members: [FamilyMember] = try await api.send(.fetchFamilyLocations(groupID: groupID))
            
            // Cache them
            for member in members {
                if let lat = member.lastLatitude, let lon = member.lastLongitude {
                    context.insert(SDFamilyMember(id: member.id, name: member.name, latitude: lat, longitude: lon, lastUpdated: member.lastUpdated ?? Date(), status: member.status.rawValue))
                }
            }
            try? context.save()
            return members
        } catch {
            let descriptor = FetchDescriptor<SDFamilyMember>()
            if let cached = try? context.fetch(descriptor), !cached.isEmpty {
                return cached.map { $0.toFamilyMember() }
            }
            throw error
        }
    }
}
