import Foundation
import WatchConnectivity
import Combine

/// Manages connectivity on the WatchOS side.
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = WatchConnectivityManager()
    
    @Published var latestAlert: [String: Any]?
    @Published var nearestShelter: [String: Any]?
    @Published var routeSummary: [String: Any]?
    
    override private init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed on Watch with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated with state: \(activationState.rawValue)")
        
        // Process any context received while inactive
        DispatchQueue.main.async {
            if !session.receivedApplicationContext.isEmpty {
                self.handlePayload(session.receivedApplicationContext)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.handlePayload(applicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.handlePayload(message)
        }
    }
    
    private func handlePayload(_ payload: [String: Any]) {
        guard let messageTypeStr = payload[WCPayloadKeys.messageType.rawValue] as? String,
              let messageType = WCMessageType(rawValue: messageTypeStr) else {
            return
        }
        
        switch messageType {
        case .newAlert:
            self.latestAlert = payload
        case .nearestShelter:
            self.nearestShelter = payload
        case .routeSummary:
            self.routeSummary = payload
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
