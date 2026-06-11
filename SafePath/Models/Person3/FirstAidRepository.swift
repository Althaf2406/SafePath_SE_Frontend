import Foundation
import Combine
import SwiftData

protocol FirstAidRepositoryProtocol {
    func fetchGuides() -> AnyPublisher<[FirstAidGuide], Error>
}

/// Person 3: Repository for first aid guide content using SwiftData.
@MainActor
final class FirstAidRepository: FirstAidRepositoryProtocol {
    
    private let context = SharedModelContainer.shared.context
    
    init() {
        seedIfNeeded()
    }
    
    private func seedIfNeeded() {
        let descriptor = FetchDescriptor<SDFirstAidGuide>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }
        
        let guides = [
            SDFirstAidGuide(id: UUID().uuidString, title: "CPR & Choking", category: "cpr", shortDescription: "Step-by-step cardiopulmonary resuscitation and Heimlich maneuver.", steps: [], iconName: "heart.fill", requiredKitNames: ["Face Shield", "Gloves"], detailedStepsTitles: [], detailedStepsDesc: []),
            SDFirstAidGuide(id: UUID().uuidString, title: "Severe Bleeding", category: "bleeding", shortDescription: "Direct pressure and tourniquet application guidelines.", steps: [], iconName: "drop.fill", requiredKitNames: ["Gauze", "Bandages", "Tourniquet"], detailedStepsTitles: [], detailedStepsDesc: []),
            SDFirstAidGuide(id: UUID().uuidString, title: "Burns", category: "burns", shortDescription: "Cooling techniques and dressing for thermal and chemical burns.", steps: [], iconName: "flame.fill", requiredKitNames: ["Burn Gel", "Non-stick Dressing"], detailedStepsTitles: [], detailedStepsDesc: []),
            SDFirstAidGuide(id: UUID().uuidString, title: "Broken Bone", category: "fractures", shortDescription: "Immobilization and splinting for suspected fractures.", steps: [], iconName: "person.crop.circle.fill.badge.plus", requiredKitNames: ["Bandage", "Clean Cloth", "Rigid Splint Material"], detailedStepsTitles: ["Keep the person still", "Do not realign the bone", "Control any bleeding", "Apply a cold pack"], detailedStepsDesc: ["Do not move the victim unless they are in immediate danger. Moving can cause further injury.", "Never attempt to push a bone back into place. Leave it exactly as you found it.", "If the bone has broken the skin, apply gentle pressure around (not directly on) the bone with a clean cloth.", "Wrap an ice pack or cold item in a cloth and apply to the area for up to 20 minutes to reduce swelling."]),
            SDFirstAidGuide(id: UUID().uuidString, title: "Sprain or Strain", category: "sprain", shortDescription: "R.I.C.E method for joint and muscle injuries.", steps: [], iconName: "figure.walk", requiredKitNames: ["Ice Pack", "Elastic Bandage"], detailedStepsTitles: [], detailedStepsDesc: [])
        ]
        
        for guide in guides {
            context.insert(guide)
        }
        try? context.save()
    }
    
    func fetchGuides() -> AnyPublisher<[FirstAidGuide], Error> {
        let descriptor = FetchDescriptor<SDFirstAidGuide>()
        do {
            let models = try context.fetch(descriptor)
            let result = models.map { model in
                var requiredKit: [FirstAidKitItem] = []
                for name in model.requiredKitNames {
                    requiredKit.append(FirstAidKitItem(id: UUID().uuidString, name: name, status: .inKit))
                }
                
                var detailedSteps: [FirstAidStep] = []
                for (index, title) in model.detailedStepsTitles.enumerated() {
                    let desc = index < model.detailedStepsDesc.count ? model.detailedStepsDesc[index] : ""
                    detailedSteps.append(FirstAidStep(id: UUID().uuidString, title: title, description: desc))
                }
                
                return FirstAidGuide(
                    id: model.id,
                    title: model.title,
                    category: model.category,
                    shortDescription: model.shortDescription,
                    steps: model.steps,
                    iconName: model.iconName,
                    requiredKit: requiredKit,
                    detailedSteps: detailedSteps
                )
            }
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
