import Foundation
import Combine

/// Person 3: Manages offline survival data, cache access, and offline emergency resources.
/// Emergency kit items are loaded from the last-known backend cache so they stay
/// up-to-date even when the device is offline.
@MainActor
final class OfflineSurvivalViewModel: ObservableObject {

    // MARK: - Published State
    @Published var offlineData: OfflineSurvivalData?
    @Published var isOfflineMode: Bool = false
    @Published var cachedEmergencyKit: [ChecklistItem] = []
    @Published var lastSyncedText: String = "Belum pernah sinkronisasi"

    private let storage = LocalStorageService.shared
    private let networkMonitor = NetworkMonitor.shared

    private let cacheKey       = "safepath.emergency_kit_cache"
    private let timestampKey   = "safepath.emergency_kit_cache_timestamp"

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init() {
        networkMonitor.$isConnected
            .map { !$0 }
            .receive(on: RunLoop.main)
            .assign(to: &$isOfflineMode)

        isOfflineMode = !networkMonitor.isConnected
        loadCachedData()
    }

    // MARK: - Load Cache

    func loadCachedData() {
        // Load emergency kit items from last successful backend fetch
        if let items: [ChecklistItem] = storage.load(forKey: cacheKey) {
            self.cachedEmergencyKit = items
        }

        // Format last sync timestamp
        if let date: Date = storage.load(forKey: timestampKey) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            lastSyncedText = "Terakhir sync: \(formatter.localizedString(for: date, relativeTo: Date()))"
        } else {
            lastSyncedText = "Belum pernah sinkronisasi"
        }
    }

    // MARK: - Computed

    var completedCount: Int { cachedEmergencyKit.filter { $0.isChecked }.count }
    var totalCount: Int     { cachedEmergencyKit.count }
    var readiness: Double   {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}
