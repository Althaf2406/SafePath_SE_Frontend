import Foundation
import WatchConnectivity
import Combine

/// Manages connectivity on the iOS side.
class IOSConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = IOSConnectivityManager()
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    private var pendingPayloads: [[String: Any]] = []
    
    func sendToWatch(payload: [String: Any]) {
        guard WCSession.isSupported() else { return }
        
        if WCSession.default.activationState == .activated {
            sendNow(payload)
        } else {
            pendingPayloads.append(payload)
            WCSession.default.activate()
        }
    }
    
    private func sendNow(_ payload: [String: Any]) {
        do {
            try WCSession.default.updateApplicationContext(payload)
        } catch {
            print("Error updating application context: \(error.localizedDescription)")
        }
        
        // Also send immediate message if watch is reachable
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("Error sending message to watch: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed on iOS with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated on iOS with state: \(activationState.rawValue)")
        
        if activationState == .activated {
            DispatchQueue.main.async {
                for payload in self.pendingPayloads {
                    self.sendNow(payload)
                }
                self.pendingPayloads.removeAll()
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Handle deactivate
        session.activate()
    }
    #endif
    
    // MARK: - Receive from Watch
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handleMessageFromWatch(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            self.handleMessageFromWatch(userInfo)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handleMessageFromWatch(applicationContext)
        }
    }
    
    private var lastActionTime = Date.distantPast
    
    private func handleMessageFromWatch(_ message: [String: Any]) {
        if Date().timeIntervalSince(lastActionTime) < 10.0 { return }
        lastActionTime = Date()
        
        print("📱 [IOSConnectivity] Diterima pesan dari Apple Watch: \(message)")
        guard let action = message["action"] as? String else {
            print("📱 [IOSConnectivity] Pesan tidak memiliki action yang valid.")
            return
        }
        
        if action == "triggerSOS" {
            print("📱 [IOSConnectivity] Memicu SOS via NotificationCenter...")
            NotificationCenter.default.post(name: Notification.Name("WatchDidTriggerSOS"), object: nil)
        } else if action == "updateStatus",
                  let data = message["data"] as? [String: Any],
                  let status = data["status"] as? String {
            print("📱 [IOSConnectivity] Memicu Update Status (\(status)) via NotificationCenter...")
            NotificationCenter.default.post(name: Notification.Name("WatchDidUpdateStatus"), object: status)
        }
    }
}
