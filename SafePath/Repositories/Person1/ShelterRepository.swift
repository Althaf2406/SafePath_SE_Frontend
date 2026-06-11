import Foundation
import Combine
import SwiftData

protocol ShelterRepositoryProtocol {
    func fetchAllShelters() async throws -> [Shelter]
    func fetchShelter(id: Int) async throws -> Shelter
    func fetchNearbyShelters(lat: Double, lng: Double) async throws -> [Shelter]
    func fetchNearbyShelters(lat: Double, lng: Double, radiusKm: Double) async throws -> [Shelter]
    func fetchRecommendedShelters(lat: Double, lng: Double, disasterType: String) async throws -> [Shelter]
}

@MainActor
final class ShelterRepository: ShelterRepositoryProtocol {
    
    private let api: APIService
    private let context = SharedModelContainer.shared.context
    
    @MainActor
    init(api: APIService? = nil) {
        self.api = api ?? APIService.shared
    }
    
    private func cacheShelters(_ shelters: [Shelter]) {
        for shelter in shelters {
            context.insert(SDShelter(id: shelter.id, name: shelter.name, address: shelter.address, latitude: shelter.latitude, longitude: shelter.longitude, capacity: shelter.capacity, availableCapacity: shelter.availableCapacity, contact: shelter.contact, facilities: shelter.facilities, shelterTypeString: shelter.shelterType.rawValue, disasterTypeSupported: shelter.disasterTypeSupported, isOpenArea: shelter.isOpenArea, buildingLevel: shelter.buildingLevel, isActive: shelter.isActive))
        }
        try? context.save()
    }
    
    private func getCachedShelters() -> [Shelter] {
        let descriptor = FetchDescriptor<SDShelter>()
        if let cached = try? context.fetch(descriptor) {
            return cached.map { $0.toShelter() }
        }
        return []
    }
    

    
    /// Fetch all shelters.
    func fetchAllShelters() async throws -> [Shelter] {
        do {
            let apiShelters: [Shelter] = try await api.fetchData(.shelters)
            cacheShelters(apiShelters)
            return apiShelters
        } catch {
            print("🚨 fetchAllShelters Decoding Error: \(error)")
            let cached = getCachedShelters()
            if !cached.isEmpty { return cached }
            throw error
        }
    }
    
    /// Fetch a single shelter by ID.
    func fetchShelter(id: Int) async throws -> Shelter {
        do {
            let apiShelter: Shelter = try await api.fetchData(.shelterDetail(id: id))
            cacheShelters([apiShelter])
            return apiShelter
        } catch {
            let cached = getCachedShelters().first(where: { $0.id == id })
            if let cached = cached { return cached }
            throw error
        }
    }
    
    /// Fetch nearby shelters within radius.
    func fetchNearbyShelters(lat: Double, lng: Double) async throws -> [Shelter] {
        return try await fetchNearbyShelters(lat: lat, lng: lng, radiusKm: AppConstants.defaultRadiusKm)
    }
    
    func fetchNearbyShelters(lat: Double, lng: Double, radiusKm: Double) async throws -> [Shelter] {
        do {
            let apiShelters: [Shelter] = try await api.fetchData(.nearbyShelters(lat: lat, lng: lng, radiusKm: radiusKm))
            cacheShelters(apiShelters)
            return apiShelters
        } catch {
            let cached = getCachedShelters()
            if !cached.isEmpty { return cached }
            throw error
        }
    }
    
    /// Fetch recommended shelters based on location and disaster type.
    func fetchRecommendedShelters(lat: Double, lng: Double, disasterType: String) async throws -> [Shelter] {
        do {
            let apiShelters: [Shelter] = try await api.fetchData(.recommendedShelters(lat: lat, lng: lng, disasterType: disasterType))
            cacheShelters(apiShelters)
            return apiShelters
        } catch {
            let cached = getCachedShelters()
            if !cached.isEmpty { return cached }
            throw error
        }
    }
}

