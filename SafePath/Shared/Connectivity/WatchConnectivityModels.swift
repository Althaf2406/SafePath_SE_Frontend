import Foundation

/// Keys used for WatchConnectivity payload dictionaries
enum WCPayloadKeys: String {
    case alertType = "alertType"
    case alertSeverity = "alertSeverity"
    case alertLocation = "alertLocation"
    case alertTimestamp = "alertTimestamp"
    
    case shelterName = "shelterName"
    case shelterType = "shelterType"
    case shelterCapacity = "shelterCapacity"
    case shelterDistance = "shelterDistance"
    case shelterAddress = "shelterAddress"
    case shelterDisasterTypes = "shelterDisasterTypes"
    
    case routeDestination = "routeDestination"
    case routeETA = "routeETA"
    case routeDistance = "routeDistance"
    
    case messageType = "messageType"
}

enum WCMessageType: String {
    case newAlert = "newAlert"
    case nearestShelter = "nearestShelter"
    case routeSummary = "routeSummary"
}
