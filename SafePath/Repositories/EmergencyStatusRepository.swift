import Foundation

/// Person 2: Repository for emergency status API calls.
/// Connects to Express backend emergency endpoints via APIService.
final class EmergencyStatusRepository: EmergencyStatusRepositoryProtocol {

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    // MARK: - Status Endpoints

    /// POST /emergency/status
    func updateStatus(
        status: EmergencyStatus.EmergencyStatusType,
        message: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws -> EmergencyStatus {
        var body: [String: Any] = ["status": status.rawValue]
        if let message   = message   { body["message"]   = message }
        if let latitude  = latitude  { body["latitude"]  = latitude }
        if let longitude = longitude { body["longitude"] = longitude }

        return try await api.send(.updateEmergencyStatus, body: body)
    }

    /// GET /emergency/status/:userId
    func fetchStatus(userID: String) async throws -> EmergencyStatus {
        return try await api.send(.fetchEmergencyStatus(userID: userID))
    }

    /// GET /emergency/family/:groupId/statuses
    func fetchFamilyStatuses(groupID: String) async throws -> [EmergencyStatus] {
        return try await api.send(.fetchFamilyStatuses(groupID: groupID))
    }

    // MARK: - SOS Endpoints

    /// POST /emergency/sos
    func triggerSOS(
        latitude: Double? = nil,
        longitude: Double? = nil,
        message: String? = nil
    ) async throws -> EmergencyStatus {
        var body: [String: Any] = [:]
        if let latitude  = latitude  { body["latitude"]  = latitude }
        if let longitude = longitude { body["longitude"] = longitude }
        if let message   = message   { body["message"]   = message }

        return try await api.send(.triggerSOS, body: body)
    }

    /// POST /emergency/sos/:sosId/resolve
    func resolveSOS(sosID: String) async throws -> EmergencyStatus {
        return try await api.send(.resolveSOS(sosID: sosID))
    }
}
