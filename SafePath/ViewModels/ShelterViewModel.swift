import Foundation
import Combine
import CoreLocation

/// Manages shelter data, filtering, and selection.
@MainActor
final class ShelterViewModel: ObservableObject {
    
    @Published var shelters: [Shelter] = []
    @Published var nearbyShelters: [Shelter] = []
    @Published var recommendedShelters: [Shelter] = []
    @Published var selectedShelter: Shelter?
    @Published var shelterDetail: Shelter?
    @Published var state: ViewState<[Shelter]> = .idle
    @Published var searchText: String = ""
    @Published var activeFilter: ShelterFilter = .nearest
    @Published var activeDisasterType: String = ""
    
    private let repository: ShelterRepositoryProtocol
    
    // MARK: - Integration hooks for Person 2
    var onShareWithFamily: ((Shelter) -> Void)?
    
    // MARK: - Integration hooks for Person 3
    var onSaveShelterOffline: ((Shelter) -> Void)?
    
    init(repository: ShelterRepositoryProtocol) {
        self.repository = repository
    }
    
    convenience init() {
        self.init(repository: ShelterRepository())
    }
    
    // MARK: - Filter Enum
    
    enum ShelterFilter: String, CaseIterable {
        case all         = "All"
        case nearest     = "Nearest"
        case recommended = "Recommended"
        case available   = "Available"
        case medical     = "Medical"
        case highGround  = "High Ground"
        case petFriendly = "Pet Friendly"
    }
    
    // MARK: - Fetch
    
    func fetchAllShelters() async {
        state = .loading
        do {
            let data = try await repository.fetchAllShelters()
            shelters = data
            state = data.isEmpty ? .empty : .loaded(data)
        } catch {
            print("⚠️ API fetchAllShelters Gagal: \(error.localizedDescription). Beralih ke data mock.")
            self.shelters = Shelter.previewList
            self.state = .loaded(Shelter.previewList)
        }
    }
    
    func fetchNearbyShelters(location: CLLocationCoordinate2D) async {
        await fetchNearbyShelters(location: location, radiusKm: AppConstants.defaultRadiusKm)
    }
    
    func fetchNearbyShelters(location: CLLocationCoordinate2D, radiusKm: Double) async {
        do {
            let data = try await repository.fetchNearbyShelters(
                lat: location.latitude,
                lng: location.longitude,
                radiusKm: radiusKm
            )
            nearbyShelters = data
            
            // Sync with Apple Watch
            sendNearestShelterToWatch()
        } catch {
            print("⚠️ Failed to fetch nearby shelters: \(error.localizedDescription). Beralih ke data mock.")
            self.nearbyShelters = Shelter.previewList
            
            // Sync with Apple Watch using mock
            sendNearestShelterToWatch()
        }
    }
    
    func fetchRecommendedShelters(location: CLLocationCoordinate2D, disasterType: String) async {
        do {
            let data = try await repository.fetchRecommendedShelters(
                lat: location.latitude,
                lng: location.longitude,
                disasterType: disasterType
            )
            recommendedShelters = data
        } catch {
            print("Failed to fetch recommended shelters: \(error.localizedDescription)")
        }
    }
    
    func fetchShelterDetail(id: Int) async {
        do {
            shelterDetail = try await repository.fetchShelter(id: id)
        } catch {
            print("Failed to fetch shelter detail: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Filtering
    
    var filteredShelters: [Shelter] {
        var result: [Shelter]
        
        // Base array selection based on filter
        switch activeFilter {
        case .nearest:
            result = nearbyShelters.isEmpty ? shelters : nearbyShelters
        case .recommended:
            result = recommendedShelters.isEmpty ? (nearbyShelters.isEmpty ? shelters : nearbyShelters) : recommendedShelters
        default:
            // For All, Available, Medical, High Ground, Pet Friendly, we search across ALL shelters.
            result = shelters
        }
        
        // Search text filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Active filter specific
        switch activeFilter {
        case .nearest, .recommended:
            result.sort { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        case .available:
            result = result.filter { $0.isActive }
        case .medical:
            result = result.filter { s in
                s.facilities.contains { f in f.localizedCaseInsensitiveContains("Medis") || f.localizedCaseInsensitiveContains("medical") }
            }
        case .highGround:
            result = result.filter { $0.buildingLevel >= 3 }
        case .petFriendly:
            result = result.filter { s in
                s.facilities.contains { f in f.localizedCaseInsensitiveContains("pet") || f.localizedCaseInsensitiveContains("hewan") }
            }
        case .all:
            break
        }
        
        return result
    }
    
    // MARK: - Selection
    
    func selectShelter(_ shelter: Shelter) {
        selectedShelter = shelter
    }
    
    // MARK: - Find Nearest Available Shelter
    
    /// Finds the nearest shelter that is active.
    func findNearestAvailable(preferMedical: Bool = false) -> Shelter? {
        let candidates = (nearbyShelters.isEmpty ? shelters : nearbyShelters)
            .filter { $0.isActive }
            .sorted { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        
        if preferMedical, let medical = candidates.first(where: { s in
            s.facilities.contains { f in f.localizedCaseInsensitiveContains("Medis") || f.localizedCaseInsensitiveContains("medical") }
        }) {
            return medical
        }
        
        return candidates.first
    }
    
    // MARK: - WatchConnectivity
    
    func sendNearestShelterToWatch() {
        guard let nearest = findNearestAvailable() else { return }
        
        let payload: [String: Any] = [
            WCPayloadKeys.messageType.rawValue: WCMessageType.nearestShelter.rawValue,
            WCPayloadKeys.shelterName.rawValue: nearest.name,
            WCPayloadKeys.shelterType.rawValue: "Relief Center", // Mocking based on typical shelter structure
            WCPayloadKeys.shelterCapacity.rawValue: "\(nearest.capacity)",
            WCPayloadKeys.shelterDistance.rawValue: nearest.distanceKm != nil ? String(format: "%.1f km", nearest.distanceKm!) : "Unknown",
            WCPayloadKeys.shelterAddress.rawValue: nearest.address,
            WCPayloadKeys.shelterDisasterTypes.rawValue: nearest.disasterTypeSupported.joined(separator: ", ")
        ]
        
        IOSConnectivityManager.shared.sendToWatch(payload: payload)
    }
}

