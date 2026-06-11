import Foundation

/// Person 2: Repository for user API calls.
/// Connects to Express backend auth & profile endpoints via APIService.
final class UserRepository: UserRepositoryProtocol {

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    // MARK: - Auth Endpoints

    /// POST /auth/register
    func register(name: String, email: String, password: String, phone: String?) async throws -> User {
        var body: [String: Any] = [
            "name":     name,
            "email":    email,
            "password": password
        ]
        if let phone = phone { body["phone"] = phone }

        return try await api.send(.register, body: body)
    }

    /// POST /auth/login
    func login(email: String, password: String) async throws -> User {
        let body: [String: Any] = [
            "email":    email,
            "password": password
        ]
        return try await api.send(.login, body: body)
    }

    /// POST /auth/logout
    func logout() async throws {
        try await api.sendVoid(.logout)
    }

    // MARK: - Profile Endpoints

    /// GET /user/profile
    func fetchProfile() async throws -> User {
        return try await api.send(.userProfile)
    }

    func updateProfile(
        name: String? = nil,
        phone: String? = nil,
        profileImageURL: String? = nil,
        bloodType: String? = nil,
        medicalConditions: String? = nil,
        emergencyContactName: String? = nil,
        emergencyContactPhone: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        deviceToken: String? = nil,
        preferences: UserPreferences? = nil
    ) async throws -> User {
        var body: [String: Any] = [:]
        if let name                  = name                  { body["name"]                      = name }
        if let phone                 = phone                 { body["phone"]                     = phone }
        if let profileImageURL       = profileImageURL       { body["profile_image_url"]         = profileImageURL }
        if let bloodType             = bloodType             { body["blood_type"]                = bloodType }
        if let medicalConditions     = medicalConditions     { body["medical_conditions"]        = medicalConditions }
        if let emergencyContactName  = emergencyContactName  { body["emergency_contact_name"]    = emergencyContactName }
        if let emergencyContactPhone = emergencyContactPhone { body["emergency_contact_phone"]   = emergencyContactPhone }
        if let latitude              = latitude              { body["latitude"]                  = latitude }
        if let longitude             = longitude             { body["longitude"]                 = longitude }
        if let deviceToken           = deviceToken           { body["device_token"]              = deviceToken }
        
        if let preferences = preferences {
            if let encoded = try? JSONEncoder().encode(preferences),
               let dict = try? JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any] {
                body["preferences"] = dict
            }
        }

        return try await api.send(.updateProfile, body: body)
    }
}
