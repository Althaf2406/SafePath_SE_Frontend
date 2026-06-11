import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var userVM = UserManagementViewModel()
    
    var body: some View {
        Group {
            if userVM.isLoggedIn {
                ActiveFamilyDashboardView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environmentObject(userVM)
    }
}

#Preview {
    ContentView()
}
