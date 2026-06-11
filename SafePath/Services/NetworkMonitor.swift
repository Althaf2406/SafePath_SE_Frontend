import Foundation
import Network
import Combine

/// Singleton that monitors network connectivity using NWPathMonitor.
/// Observe `isConnected` to react to online/offline changes.
final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.safepath.network-monitor", qos: .background)

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
