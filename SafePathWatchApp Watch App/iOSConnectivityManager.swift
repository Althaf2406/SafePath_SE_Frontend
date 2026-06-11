import Foundation
import WatchConnectivity
import Combine

class iOSConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    @Published var latestAlert: String = ""
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("⌚️ [WatchConnectivity] Activation completed with state: \(activationState.rawValue), error: \(String(describing: error))")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    func sendActionToiOS(action: String, data: [String: Any]? = nil) {
        var payload: [String: Any] = ["action": action]
        if let data = data {
            payload["data"] = data
        }
        
        // 1. Update Application Context (sangat reliable di Simulator)
        do {
            try session.updateApplicationContext(payload)
            print("⌚️ [WatchConnectivity] Berhasil set updateApplicationContext.")
        } catch {
            print("⌚️ [WatchConnectivity] Gagal set applicationContext: \(error.localizedDescription)")
        }
        
        // 2. Transfer User Info (antrean background)
        print("⌚️ [WatchConnectivity] Antri kirim pesan via transferUserInfo: \(payload)")
        session.transferUserInfo(payload)
        
        if session.isReachable {
            print("⌚️ [WatchConnectivity] Session isReachable! Mengirim pesan langsung via sendMessage...")
            session.sendMessage(payload, replyHandler: nil) { error in
                print("⌚️ [WatchConnectivity] Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("⌚️ [WatchConnectivity] Session is not reachable! Message hanya dikirim via transferUserInfo.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let alert = message["alert"] as? String {
                self.latestAlert = alert
            }
        }
    }
}
