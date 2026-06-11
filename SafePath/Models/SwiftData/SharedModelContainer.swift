import Foundation
import SwiftData

@MainActor
class SharedModelContainer {
    static let shared = SharedModelContainer()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
            SDFamilyMember.self, SDShelter.self, SDFirstAidGuide.self, SDDisasterPreparationGuide.self,
            SDEmergencyKitItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var context: ModelContext {
        container.mainContext
    }
}
