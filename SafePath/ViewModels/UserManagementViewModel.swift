import Foundation
import Combine

/// Person 2: Manages user registration, login, logout, and profile.
/// Singleton shared via @EnvironmentObject — inject once at SafePathApp level.
@MainActor
final class UserManagementViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init — restore persisted session

    init(repository: UserRepositoryProtocol? = nil) {
        self.repository = repository ?? UserRepository()
        self.currentUser = SessionManager.shared.currentUser
        self.isLoggedIn = SessionManager.shared.isLoggedIn
        // Mock removed to enforce API integration
    }

    // MARK: - Auth Actions

    /// POST /auth/register — Registers a new user account.
    func register(name: String, email: String, password: String, phone: String? = nil) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let newUser = try await repository.register(name: name, email: email, password: password, phone: phone)
            self.currentUser = newUser
            self.isLoggedIn = true
            SessionManager.shared.saveUser(newUser)
        } catch {
            errorMessage = error.localizedDescription
            self.isLoggedIn = false
        }

        isLoading = false
    }

    /// POST /auth/login — Authenticates user and stores session.
    func login(email: String, password: String) async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await repository.login(email: email, password: password)
            self.currentUser = user
            self.isLoggedIn = true
            SessionManager.shared.saveUser(user)

            // Refresh full profile so family_group_ids is always up-to-date
            if let freshUser = try? await repository.fetchProfile() {
                // Preserve auth token from login response (fetchProfile doesn't return one)
                var merged = freshUser
                merged = User(
                    id: freshUser.id, name: freshUser.name, email: freshUser.email,
                    phone: freshUser.phone, profileImageURL: freshUser.profileImageURL,
                    bloodType: freshUser.bloodType, medicalConditions: freshUser.medicalConditions,
                    emergencyContactName: freshUser.emergencyContactName,
                    emergencyContactPhone: freshUser.emergencyContactPhone,
                    createdAt: freshUser.createdAt, lastLatitude: freshUser.lastLatitude,
                    lastLongitude: freshUser.lastLongitude, locationUpdatedAt: freshUser.locationUpdatedAt,
                    authToken: user.authToken, refreshToken: user.refreshToken,
                    deviceToken: freshUser.deviceToken, familyGroupIDs: freshUser.familyGroupIDs,
                    preferences: freshUser.preferences
                )
                self.currentUser = merged
                SessionManager.shared.saveUser(merged)
            }
        } catch {
            errorMessage = error.localizedDescription
            self.isLoggedIn = false
        }

        isLoading = false
    }

    /// POST /auth/logout — Clears session.
    func logout() async {
        isLoading = true
        errorMessage = nil

        // Optimistic UI update: hapus session lokal segera agar langsung redirect ke Login
        self.currentUser = nil
        self.isLoggedIn = false
        SessionManager.shared.clearSession()

        do {
            try await repository.logout()
        } catch {
            errorMessage = error.localizedDescription
            print("Backend logout failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // MARK: - Profile Actions

    /// GET /user/profile — Fetches the latest profile from backend.
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await repository.fetchProfile()
            self.currentUser = user
            SessionManager.shared.saveUser(user)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// PUT /user/profile — Updates name, phone, profile image, medical info, or location.
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
        deviceToken: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let updatedUser = try await repository.updateProfile(
                name: name, 
                phone: phone, 
                profileImageURL: profileImageURL, 
                bloodType: bloodType,
                medicalConditions: medicalConditions,
                emergencyContactName: emergencyContactName,
                emergencyContactPhone: emergencyContactPhone,
                latitude: latitude, 
                longitude: longitude,
                deviceToken: deviceToken,
                preferences: nil
            )
            self.currentUser = updatedUser
            self.isLoading   = false
            SessionManager.shared.saveUser(updatedUser)
        } catch {
            errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    // MARK: - Helpers

    /// PUT /user/profile — Updates settings preferences
    func updatePreferences(_ prefs: UserPreferences) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedUser = try await repository.updateProfile(
                name: nil,
                phone: nil,
                profileImageURL: nil,
                bloodType: nil,
                medicalConditions: nil,
                emergencyContactName: nil,
                emergencyContactPhone: nil,
                latitude: nil,
                longitude: nil,
                deviceToken: nil,
                preferences: prefs
            )
            self.currentUser = updatedUser
            self.isLoading = false
            SessionManager.shared.saveUser(updatedUser)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    /// Clears any displayed error message.
    func clearError() {
        errorMessage = nil
    }

}
