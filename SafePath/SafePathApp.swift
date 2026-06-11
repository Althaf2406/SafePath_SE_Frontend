import SwiftUI
import Combine
import SwiftData
import CoreLocation

@main
struct SafePathApp: App {
    @StateObject private var locationService = LocationService()
    @StateObject private var userVM = UserManagementViewModel()
    @StateObject var preparednessViewModel = PreparednessViewModel()
    @StateObject private var emergencyVM = EmergencyStatusViewModel(isPrimaryObserver: true)

    init() {
        // Activate WCSession on the iOS side on launch
        _ = IOSConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(locationService)
                .environmentObject(userVM)
                .environmentObject(preparednessViewModel)
                .environmentObject(emergencyVM)
                .onAppear {
                    locationService.requestPermission()
                }
        }
        .modelContainer(SharedModelContainer.shared.container)
    }
}

/// RootView: decides whether to show Login or the main TabView
/// based on UserManagementViewModel.isLoggedIn
struct RootView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        Group {
            if userVM.isLoggedIn {
                AppRouter()
            } else {
                LoginView()
            }
        }
        .onChange(of: locationService.currentLocation) { newLocation in
            guard let loc = newLocation, userVM.isLoggedIn else { return }
            Task {
                // Update coordinate location to backend via GPS
                await userVM.updateProfile(latitude: loc.latitude, longitude: loc.longitude)
            }
        }
    }
}
