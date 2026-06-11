import Foundation
import Combine

/// Centralized session management for user authentication and state.
final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentUser: User? {
        didSet {
            persistSession()
        }
    }
    
    private let sessionKey = "safepath_current_user"
    
    var authToken: String? {
        currentUser?.authToken
    }
    
    var isLoggedIn: Bool {
        currentUser?.isAuthenticated == true
    }
    
    private init() {
        restoreSession()
    }
    
    func saveUser(_ user: User) {
        self.currentUser = user
    }
    
    func clearSession() {
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }
    
    private func persistSession() {
        guard let user = currentUser else { return }
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
    }
    
    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let user = try? JSONDecoder().decode(User.self, from: data),
              user.isAuthenticated else { return }
        self.currentUser = user
    }
}
