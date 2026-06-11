import Foundation

protocol EmergencyStatusRepositoryProtocol {
    func updateStatus(
        status: EmergencyStatus.EmergencyStatusType,
        message: String?,
        latitude: Double?,
        longitude: Double?
    ) async throws -> EmergencyStatus

    func fetchStatus(userID: String) async throws -> EmergencyStatus

    func fetchFamilyStatuses(groupID: String) async throws -> [EmergencyStatus]

    func triggerSOS(
        latitude: Double?,
        longitude: Double?,
        message: String?
    ) async throws -> EmergencyStatus

    func resolveSOS(sosID: String) async throws -> EmergencyStatus
}
