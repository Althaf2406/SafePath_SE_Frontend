import Foundation
import Combine
import SwiftData

protocol DisasterPreparationRepositoryProtocol {
    func fetchGuides() -> AnyPublisher<[DisasterPreparationGuide], Error>
}

/// Repository for disaster preparation guides using SwiftData.
@MainActor
final class DisasterPreparationRepository: DisasterPreparationRepositoryProtocol {
    
    private let context = SharedModelContainer.shared.context
    
    init() {
        seedIfNeeded()
    }
    
    private func seedIfNeeded() {
        let descriptor = FetchDescriptor<SDDisasterPreparationGuide>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }
        
        let guides = [
            SDDisasterPreparationGuide(id: UUID().uuidString, disasterType: "Flood", title: "Flood Preparation Guide", guideDescription: "Essential steps to take before, during, and after a flood.", handlingProcedures: ["Evacuate immediately to higher ground if advised.", "Do not walk, swim, or drive through floodwaters.", "Turn off utilities at the main switches if instructed.", "Disconnect electrical appliances before the flood hits."], iconName: "cloud.heavyrain.fill"),
            SDDisasterPreparationGuide(id: UUID().uuidString, disasterType: "Earthquake", title: "Earthquake Preparation Guide", guideDescription: "What to do to stay safe when the ground starts shaking.", handlingProcedures: ["Drop, Cover, and Hold On.", "Stay away from windows, glass, and anything that could fall.", "If outdoors, move to an open area away from buildings and trees.", "If in a vehicle, pull over and stay inside until shaking stops."], iconName: "waveform.path.ecg"),
            SDDisasterPreparationGuide(id: UUID().uuidString, disasterType: "Fire", title: "Wildfire Preparation Guide", guideDescription: "Protect yourself and your home from wildfires.", handlingProcedures: ["Evacuate immediately if an evacuation order is given.", "Keep doors and windows closed to prevent drafts.", "Shut off gas valves if advised.", "Keep a hose connected to outside taps."], iconName: "flame.fill")
        ]
        
        for guide in guides {
            context.insert(guide)
        }
        try? context.save()
    }
    
    func fetchGuides() -> AnyPublisher<[DisasterPreparationGuide], Error> {
        let descriptor = FetchDescriptor<SDDisasterPreparationGuide>()
        do {
            let models = try context.fetch(descriptor)
            let result = models.map { $0.toDisasterPreparationGuide() }
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
