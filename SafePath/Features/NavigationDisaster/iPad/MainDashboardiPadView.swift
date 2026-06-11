import SwiftUI

enum DashboardTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case alerts = "Disaster Alerts"
    case shelters = "Shelter Directory"
    case evacuation = "Evacuation Route"
    case mapCommand = "Map Command Center"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .alerts: return "exclamationmark.triangle"
        case .shelters: return "house"
        case .evacuation: return "figure.run"
        case .mapCommand: return "map"
        }
    }
}

struct MainDashboardiPadView: View {
    @State private var selectedTab: DashboardTab? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            List(DashboardTab.allCases, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.rawValue, systemImage: tab.iconName)
                        .font(.title3)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("SafePath")
        } detail: {
            if let tab = selectedTab {
                switch tab {
                case .dashboard:
                    iPadDashboardContentView()
                case .alerts:
                    DisasterAlertDashboardiPadView()
                case .shelters:
                    ShelterDirectoryiPadView()
                case .evacuation:
                    EvacuationDashboardiPadView()
                case .mapCommand:
                    MapCommandCenteriPadView()
                }
            } else {
                Text("Select a module from the sidebar")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct iPadDashboardContentView: View {
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome to SafePath Command")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    DashboardCard(title: "Active Disaster Alerts", icon: "exclamationmark.triangle.fill", color: .red) {
                        Text("3 Active Alerts Nearby")
                            .font(.headline)
                    }
                    
                    DashboardCard(title: "Nearby Shelters", icon: "house.fill", color: .green) {
                        Text("12 Shelters Available")
                            .font(.headline)
                    }
                    
                    DashboardCard(title: "Recommended Shelter", icon: "star.fill", color: .orange) {
                        VStack(alignment: .leading) {
                            Text("City Hall Relief Center")
                                .font(.headline)
                            Text("2.5 km away • 80% Capacity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    DashboardCard(title: "Current Location", icon: "location.fill", color: .blue) {
                        Text("Downtown District, Zone A")
                            .font(.headline)
                    }
                    
                    DashboardCard(title: "Evacuation Status", icon: "figure.run", color: .purple) {
                        Text("Ready to Evacuate")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .padding(12)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            content
                .padding(.top, 4)
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(minHeight: 160)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MainDashboardiPadView()
}
