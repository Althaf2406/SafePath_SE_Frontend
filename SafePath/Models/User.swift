import Foundation

/// Represents a registered SafePath user.
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var phone: String?
    var profileImageURL: String?
    
    // Medical & Emergency Info
    var bloodType: String?
    var medicalConditions: String?
    var emergencyContactName: String?
    var emergencyContactPhone: String?
    
    // Location Accuracy
    var createdAt: Date?
    var lastLatitude: Double?
    var lastLongitude: Double?
    var locationUpdatedAt: Date?

    // Person 2 — Authentication & family references
    var authToken: String?
    var refreshToken: String?
    var deviceToken: String?
    var familyGroupIDs: [String]
    
    // User Settings
    var preferences: UserPreferences?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case profileImageURL         = "profile_image_url"
        case bloodType               = "blood_type"
        case medicalConditions       = "medical_conditions"
        case emergencyContactName    = "emergency_contact_name"
        case emergencyContactPhone   = "emergency_contact_phone"
        case createdAt               = "created_at"
        case lastLatitude            = "last_latitude"
        case lastLongitude           = "last_longitude"
        case locationUpdatedAt       = "location_updated_at"
        case authToken               = "auth_token"
        case refreshToken            = "refresh_token"
        case deviceToken             = "device_token"
        case familyGroupIDs          = "family_group_ids"
        case preferences             = "preferences"
    }

    // MARK: - Helpers

    /// Returns true when the user has a valid auth token present.
    var isAuthenticated: Bool {
        authToken != nil && !(authToken!.isEmpty)
    }

    /// Returns true when the user belongs to at least one family group.
    var hasFamilyGroup: Bool {
        !familyGroupIDs.isEmpty
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        phone: String? = nil,
        profileImageURL: String? = nil,
        bloodType: String? = nil,
        medicalConditions: String? = nil,
        emergencyContactName: String? = nil,
        emergencyContactPhone: String? = nil,
        createdAt: Date? = Date(),
        lastLatitude: Double? = nil,
        lastLongitude: Double? = nil,
        locationUpdatedAt: Date? = nil,
        authToken: String? = nil,
        refreshToken: String? = nil,
        deviceToken: String? = nil,
        familyGroupIDs: [String] = [],
        preferences: UserPreferences? = nil
    ) {
        self.id                    = id
        self.name                  = name
        self.email                 = email
        self.phone                 = phone
        self.profileImageURL       = profileImageURL
        self.bloodType             = bloodType
        self.medicalConditions     = medicalConditions
        self.emergencyContactName  = emergencyContactName
        self.emergencyContactPhone = emergencyContactPhone
        self.createdAt             = createdAt
        self.lastLatitude          = lastLatitude
        self.lastLongitude         = lastLongitude
        self.locationUpdatedAt     = locationUpdatedAt
        self.authToken             = authToken
        self.refreshToken          = refreshToken
        self.deviceToken           = deviceToken
        self.familyGroupIDs        = familyGroupIDs
        self.preferences           = preferences
    }
}
