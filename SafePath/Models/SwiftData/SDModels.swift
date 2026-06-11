import Foundation
import SwiftData
import CoreLocation

// MARK: - SDFamilyMember
@Model
class SDFamilyMember {
    @Attribute(.unique) var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var lastUpdated: Date
    var status: String
    
    init(id: String, name: String, latitude: Double, longitude: Double, lastUpdated: Date, status: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lastUpdated = lastUpdated
        self.status = status
    }
    
    func toFamilyMember() -> FamilyMember {
        return FamilyMember(
            id: id,
            name: name,
            lastLatitude: latitude,
            lastLongitude: longitude,
            lastUpdated: lastUpdated,
            status: FamilyMember.MemberStatus(rawValue: status) ?? .unknown
        )
    }
}

// MARK: - SDShelter
@Model
class SDShelter {
    @Attribute(.unique) var id: Int
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var capacity: Int
    var availableCapacity: Int?
    var contact: String?
    var facilities: [String]
    var shelterTypeString: String
    var disasterTypeSupported: [String]
    var isOpenArea: Bool
    var buildingLevel: Int
    var isActive: Bool
    
    init(id: Int, name: String, address: String, latitude: Double, longitude: Double, capacity: Int, availableCapacity: Int?, contact: String?, facilities: [String], shelterTypeString: String, disasterTypeSupported: [String], isOpenArea: Bool, buildingLevel: Int, isActive: Bool) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.capacity = capacity
        self.availableCapacity = availableCapacity
        self.contact = contact
        self.facilities = facilities
        self.shelterTypeString = shelterTypeString
        self.disasterTypeSupported = disasterTypeSupported
        self.isOpenArea = isOpenArea
        self.buildingLevel = buildingLevel
        self.isActive = isActive
    }
    
    // Converter to standard model
    func toShelter() -> Shelter {
        return Shelter(
            id: id,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            capacity: capacity,
            availableCapacity: availableCapacity,
            contact: contact,
            facilities: facilities,
            shelterType: ShelterType(rawValue: shelterTypeString) ?? .building,
            disasterTypeSupported: disasterTypeSupported,
            isOpenArea: isOpenArea,
            buildingLevel: buildingLevel,
            isActive: isActive
        )
    }
}

// MARK: - SDFirstAidGuide
@Model
class SDFirstAidGuide {
    @Attribute(.unique) var id: String
    var title: String
    var category: String
    var shortDescription: String
    var steps: [String]
    var iconName: String?
    
    // Simplified structures since SwiftData has issues with deeply nested custom arrays
    var requiredKitNames: [String]
    var detailedStepsTitles: [String]
    var detailedStepsDesc: [String]
    
    init(id: String, title: String, category: String, shortDescription: String, steps: [String], iconName: String?, requiredKitNames: [String], detailedStepsTitles: [String], detailedStepsDesc: [String]) {
        self.id = id
        self.title = title
        self.category = category
        self.shortDescription = shortDescription
        self.steps = steps
        self.iconName = iconName
        self.requiredKitNames = requiredKitNames
        self.detailedStepsTitles = detailedStepsTitles
        self.detailedStepsDesc = detailedStepsDesc
    }
}

// MARK: - SDDisasterPreparationGuide
@Model
class SDDisasterPreparationGuide {
    @Attribute(.unique) var id: String
    var disasterType: String
    var title: String
    var guideDescription: String
    var handlingProcedures: [String]
    var iconName: String
    
    init(id: String, disasterType: String, title: String, guideDescription: String, handlingProcedures: [String], iconName: String) {
        self.id = id
        self.disasterType = disasterType
        self.title = title
        self.guideDescription = guideDescription
        self.handlingProcedures = handlingProcedures
        self.iconName = iconName
    }
    
    func toDisasterPreparationGuide() -> DisasterPreparationGuide {
        return DisasterPreparationGuide(
            id: id,
            disasterType: disasterType,
            title: title,
            description: guideDescription,
            handlingProcedures: handlingProcedures,
            iconName: iconName
        )
    }
}
// MARK: - SDEmergencyKitItem (checked state for hardcoded items, per user)
@Model
class SDEmergencyKitItem {
    /// Composite key: "<userID>_<itemID>"
    @Attribute(.unique) var compositeKey: String
    var itemId: String
    var userId: String
    var isChecked: Bool
    var updatedAt: Date

    init(itemId: String, userId: String, isChecked: Bool) {
        self.compositeKey = "\(userId)_\(itemId)"
        self.itemId = itemId
        self.userId = userId
        self.isChecked = isChecked
        self.updatedAt = Date()
    }
}
