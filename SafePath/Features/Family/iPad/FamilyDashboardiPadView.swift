import SwiftUI

struct FamilyDashboardiPadView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ActiveFamilyDashboardiPadView()
        }
    }
}

#Preview {
    FamilyDashboardiPadView()
        .environmentObject(UserManagementViewModel())
}
