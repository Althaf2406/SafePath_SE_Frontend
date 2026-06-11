import Foundation
import Combine

/// Person 2: Manages emergency status updates and SOS triggers.
@MainActor
final class EmergencyStatusViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentStatus: EmergencyStatus?
    @Published var familyStatuses: [EmergencyStatus] = []
    @Published var isLoading: Bool = false
    @Published var isSOSActive: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let repository: EmergencyStatusRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: EmergencyStatusRepositoryProtocol? = nil, isPrimaryObserver: Bool = false) {
        self.repository = repository ?? EmergencyStatusRepository()
        
        if isPrimaryObserver {
            NotificationCenter.default.addObserver(forName: Notification.Name("WatchDidTriggerSOS"), object: nil, queue: .main) { [weak self] _ in
                print("🚨 [EmergencyStatusViewModel] Notifikasi WatchDidTriggerSOS diterima!")
                Task {
                    await self?.triggerSOS()
                }
            }
            
            NotificationCenter.default.addObserver(forName: Notification.Name("WatchDidUpdateStatus"), object: nil, queue: .main) { [weak self] notification in
                if let statusStr = notification.object as? String {
                    print("🚨 [EmergencyStatusViewModel] Notifikasi WatchDidUpdateStatus (\(statusStr)) diterima!")
                    Task {
                        let message = "Status updated from Apple Watch: \(statusStr)"
                        if statusStr == "Safe" {
                            await self?.updateStatus(status: .safe, message: message)
                        } else if statusStr == "Need Help" {
                            await self?.updateStatus(status: .sos, message: message)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Status Actions

    /// POST /emergency/status — Updates the current user's emergency status.
    func updateStatus(
        status: EmergencyStatus.EmergencyStatusType,
        message: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.updateStatus(
                status: status,
                message: message,
                latitude: latitude,
                longitude: longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Convenience — marks user as safe and updates status.
    func markSafe(latitude: Double? = nil, longitude: Double? = nil) async {
        await updateStatus(status: .safe, latitude: latitude, longitude: longitude)
    }

    /// GET /emergency/status/:userId — Fetches current user's status
    func fetchStatus(userID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.fetchStatus(userID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// GET /emergency/family/:groupId/statuses — Fetches statuses for all family members.
    func fetchFamilyStatuses(groupID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            familyStatuses = try await repository.fetchFamilyStatuses(groupID: groupID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - SOS Actions

    /// POST /emergency/sos — Triggers SOS and notifies all family members.
    func triggerSOS(
        latitude: Double? = nil,
        longitude: Double? = nil,
        message: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.triggerSOS(
                latitude: latitude,
                longitude: longitude,
                message: message
            )
            isSOSActive = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// POST /emergency/sos/:id/resolve — Resolves an active SOS.
    func resolveSOS() async {
        guard let sosID = currentStatus?.id else { return }
        isLoading = true
        errorMessage = nil
        do {
            currentStatus = try await repository.resolveSOS(sosID: sosID)
            isSOSActive = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    /// Clears any displayed error message.
    func clearError() {
        errorMessage = nil
    }
}
