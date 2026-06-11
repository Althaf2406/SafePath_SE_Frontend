import SwiftUI
import Combine

/// Tab-based navigation for SafePath matching the screenshots.
struct AppRouter: View {
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var userVM: UserManagementViewModel
    @State private var selectedTab: Tab = .family
    @State private var showProfile = false
    
    enum Tab: String {
        case home     = "Home"
        case map      = "Map"
        case shelter  = "Shelter"
        case family   = "Family"      // Person 2
        case prep     = "Prep"        // Person 3
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customTopBar
            
            TabView(selection: $selectedTab) {
                // ── Tab 1: Home (Disaster Alerts) ─────────────────────────────
            NavigationStack {
                DisasterAlertView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)
            
            // ── Tab 2: Map ────────────────────────────────────────────────
            MainMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(Tab.map)
            
            // ── Tab 3: Shelter ────────────────────────────────────────────
            NavigationStack {
                ShelterListView()
            }
            .tabItem {
                Label("Shelter", systemImage: "mappin.circle.fill")
            }
            .tag(Tab.shelter)
            
            Group {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if let user = userVM.currentUser, !user.familyGroupIDs.isEmpty {
                        FamilyDashboardiPadView()
                    } else {
                        NavigationStack {
                            FamilyDashboardView()
                        }
                    }
                } else {
                    NavigationStack {
                        if let user = userVM.currentUser, !user.familyGroupIDs.isEmpty {
                            ActiveFamilyDashboardView()
                        } else {
                            FamilyDashboardView()
                        }
                    }
                }
            }
                .tabItem {
                    Label("Family", systemImage: "person.2.fill")
                }
                .tag(Tab.family)
            
            // ── Tab 5: Prep (Person 3 Placeholder UI) ─────────────────────
            PreparednessView()
                .tabItem {
                    Label("Prep", systemImage: "checklist")
                }
                .tag(Tab.prep)
        }
        }
        .tint(SafePathColors.primaryBlue)
        .fullScreenCover(isPresented: $showProfile) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                ProfilePageiPadView()
            } else {
                ProfilePageView()
            }
        }
    }
    
    private var customTopBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { selectedTab = .home }) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(SafePathColors.primaryBlue)
                            .font(.system(size: 24, weight: .bold))
                        Text("SafePath")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }
                }
                
                Spacer()
                
                Button(action: { showProfile = true }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 34, height: 34)
                        .foregroundColor(SafePathColors.textSecondary.opacity(0.4))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            
            Divider()
        }
        .background(Color.white)
    }
}

// MARK: - Preview
#if DEBUG
struct AppRouter_Previews: PreviewProvider {
    static var previews: some View {
        AppRouter()
            .environmentObject(LocationService())
            .environmentObject(UserManagementViewModel())
    }
}
#endif
