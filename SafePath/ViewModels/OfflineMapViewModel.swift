import Foundation
import Combine

/// Person 3: Manages offline map downloads and state.
@MainActor
final class OfflineMapViewModel: ObservableObject {
    // TODO: Person 3 will implement map tile download, storage management, and region selection.
    
    @Published var downloadedMaps: [OfflineMap] = []
    @Published var isDownloading: Bool = false
}
