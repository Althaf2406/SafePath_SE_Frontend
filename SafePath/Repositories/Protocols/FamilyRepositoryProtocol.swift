import Foundation

protocol FamilyRepositoryProtocol {
    func createGroup(name: String) async throws -> FamilyGroup
    func joinGroup(inviteCode: String) async throws -> FamilyGroup
    func leaveGroup(groupID: String) async throws
    func fetchGroup(groupID: String) async throws -> FamilyGroup
    func fetchAllGroups() async throws -> [FamilyGroup]
    
    func inviteMember(
        groupID: String,
        phone: String?,
        email: String?
    ) async throws -> FamilyMember
    
    func removeMember(groupID: String, memberID: String) async throws
    
    func updateMemberStatus(
        groupID: String,
        memberID: String,
        status: FamilyMember.MemberStatus
    ) async throws -> FamilyMember
    
    func shareLocation(
        groupID: String,
        latitude: Double,
        longitude: Double
    ) async throws
    
    func fetchFamilyLocations(groupID: String) async throws -> [FamilyMember]
}
