import Foundation
import Combine

/// Person 3: Manages first aid guide data.
@MainActor
final class FirstAidGuideViewModel: ObservableObject {
    
    @Published var guides: [FirstAidGuide] = []
    @Published var selectedGuide: FirstAidGuide?
    @Published var searchQuery: String = ""
    
    private let repository: FirstAidRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: FirstAidRepositoryProtocol? = nil) {
        self.repository = repository ?? FirstAidRepository()
        loadGuides()
    }
    
    var filteredGuides: [FirstAidGuide] {
        if searchQuery.isEmpty {
            return guides
        } else {
            return guides.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) || $0.shortDescription.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    func loadGuides() {
        repository.fetchGuides()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching guides: \(error)")
                }
            } receiveValue: { [weak self] fetchedGuides in
                self?.guides = fetchedGuides
            }
            .store(in: &cancellables)
    }
}
