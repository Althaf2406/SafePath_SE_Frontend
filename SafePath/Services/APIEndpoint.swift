import Foundation
import Combine

/// Defines all SafePath API endpoint paths.
enum APIEndpoint {
    case disasterAlerts
    case nearbyAlerts(lat: Double, lng: Double, radiusKm: Double)
    case weatherAlert(adm4: String)
    case shelters
    case shelterDetail(id: Int)
    case nearbyShelters(lat: Double, lng: Double, radiusKm: Double)
    case recommendedShelters(lat: Double, lng: Double, disasterType: String)
    case evacuationRoute(originLat: Double, originLng: Double, destLat: Double, destLng: Double)
    
    //user
    case register
    case login
    case logout
    case userProfile
    case updateProfile
    
    //fam
    case createFamilyGroup
    case joinFamilyGroup
    case leaveGroup(groupID: String)
    case fetchFamilyGroup(groupID: String)
    case fetchAllFamilyGroups
    case inviteFamilyMember(groupID: String)
    case removeFamilyMember(groupID: String, memberID: String)
    case updateFamilyMemberStatus(groupID: String, memberID: String)
    case shareLocation
    case fetchFamilyLocations(groupID: String)
    
    //emegrncy
    case updateEmergencyStatus
    case fetchEmergencyStatus(userID: String)
    case fetchFamilyStatuses(groupID: String)
    case triggerSOS
    case resolveSOS(sosID: String)
    
    //preparedness
    case getAllItem
    case createItem
    case updateItem(id: String)
    case deleteItem(id: String)
    case riskProfiles(lat: Double, lng: Double)
    case disasterGuides
    
    var path: String {
        switch self {
        case .disasterAlerts:
            return "/disaster-alert"
        case .nearbyAlerts(let lat, let lng, let radiusKm):
            return "/disaster-alert/nearby?lat=\(lat)&lng=\(lng)&radiusKm=\(radiusKm)"
        case .weatherAlert(let adm4):
            return "/weather-alert?adm4=\(adm4)"
        case .shelters:
            return "/shelters"
        case .shelterDetail(let id):
            return "/shelters/\(id)"
        case .nearbyShelters(let lat, let lng, let radiusKm):
            return "/shelters/nearby?lat=\(lat)&lng=\(lng)&radiusKm=\(radiusKm)"
        case .recommendedShelters(let lat, let lng, let disasterType):
            return "/shelters/recommended?lat=\(lat)&lng=\(lng)&disasterType=\(disasterType)"
        case .evacuationRoute(let originLat, let originLng, let destLat, let destLng):
            return "/evacuation-route?originLat=\(originLat)&originLng=\(originLng)&destLat=\(destLat)&destLng=\(destLng)"
            
            //auth
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .logout:
            return "/auth/logout"
        case .userProfile, .updateProfile:
            return "/user/profile"
            
            //fam
        case .createFamilyGroup:
            return "/family/group"
        case .joinFamilyGroup:
            return "/family/join"
        case .leaveGroup(let groupID):
            return "/family/group/\(groupID)/leave"
        case .fetchFamilyGroup(let groupID):
            return "/family/group/\(groupID)"
        case .fetchAllFamilyGroups:
            return "/family/groups"
        case .inviteFamilyMember(let groupID):
            return "/family/group/\(groupID)/invite"
        case .removeFamilyMember(let groupID, let memberID):
            return "/family/group/\(groupID)/member/\(memberID)"
        case .updateFamilyMemberStatus(let groupID, let memberID):
            return "/family/group/\(groupID)/member/\(memberID)/status"
        case .shareLocation:
            return "/family/location"
        case .fetchFamilyLocations(let groupID):
            return "/family/group/\(groupID)/locations"
            
            //emgrncy
        case .updateEmergencyStatus:
            return "/emergency/status"
        case .fetchEmergencyStatus(let userID):
            return "/emergency/status/\(userID)"
        case .fetchFamilyStatuses(let groupID):
            return "/emergency/family/\(groupID)/statuses"
        case .triggerSOS:
            return "/emergency/sos"
        case .resolveSOS(let sosID):
            return "/emergency/sos/\(sosID)/resolve"
            
            //checklist item
        case .getAllItem:
            return "/item"
        case .createItem:
            return "/item"
        case .updateItem(let id):
            return "/item/\(id)"
        case .deleteItem(let id):
            return "/item/\(id)"
        case .riskProfiles(let lat, let lng):
            return "/preparedness/risk-profiles?lat=\(lat)&lng=\(lng)"
        case .disasterGuides:
            return "/preparedness/disaster-guides"
        }
        
    }
    
    var method: String {
        switch self {
        case .register, .login, .logout,
                .createFamilyGroup, .joinFamilyGroup, .inviteFamilyMember, .shareLocation,
                .updateEmergencyStatus, .triggerSOS, .resolveSOS,
                .createItem:
            return "POST"
        case .updateProfile, .updateFamilyMemberStatus, .updateItem:
            return "PUT"
        case .removeFamilyMember, .deleteItem, .leaveGroup:
            return "DELETE"
        default:
            return "GET"
        }
    }
    
    /// Full URL combining base URL and path.
    var url: URL? {
        URL(string: AppConstants.apiBaseURL + path)
    }
}
