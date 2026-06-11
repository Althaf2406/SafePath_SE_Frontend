import Foundation

protocol UserRepositoryProtocol {
    func register(name: String, email: String, password: String, phone: String?) async throws -> User
    func login(email: String, password: String) async throws -> User
    func logout() async throws
    func fetchProfile() async throws -> User
    func updateProfile(
        name: String?,
        phone: String?,
        profileImageURL: String?,
        bloodType: String?,
        medicalConditions: String?,
        emergencyContactName: String?,
        emergencyContactPhone: String?,
        latitude: Double?,
        longitude: Double?,
        deviceToken: String?,
        preferences: UserPreferences?
    ) async throws -> User
}
