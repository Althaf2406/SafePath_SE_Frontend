import Foundation
import Combine

@MainActor
final class DisasterPreparationViewModel: ObservableObject {
    
    @Published var guides: [DisasterPreparationGuide] = []
    @Published var checklistItems: [ChecklistItem] = []
    
    private let prepRepository: DisasterPreparationRepositoryProtocol
    private let checklistRepository: ChecklistRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        prepRepository: DisasterPreparationRepositoryProtocol? = nil,
        checklistRepository: ChecklistRepositoryProtocol? = nil
    ) {
        self.prepRepository = prepRepository ?? DisasterPreparationRepository()
        self.checklistRepository = checklistRepository ?? ChecklistRepository()
        loadGuides()
    }
    
    func loadGuides() {
        prepRepository.fetchGuides()
            .receive(on: RunLoop.main)
            .sink { _ in } receiveValue: { [weak self] fetchedGuides in
                self?.guides = fetchedGuides
            }
            .store(in: &cancellables)
    }
    
    func loadChecklist(for disasterType: String) {
        checklistRepository.fetchItems(forDisasterType: disasterType)
            .receive(on: RunLoop.main)
            .sink { _ in } receiveValue: { [weak self] items in
                self?.checklistItems = items
            }
            .store(in: &cancellables)
    }
    
}
