import SwiftUI
import Combine

/// Displays a scrollable list of shelters with search and filter chips.
struct ShelterListView: View {
    @StateObject private var viewModel = ShelterViewModel()
    @EnvironmentObject var locationService: LocationService
    
    /// Callback when user wants to navigate to a shelter on the map.
    var onSelectShelterForRoute: ((Shelter) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                SafePathColors.backgroundLight.ignoresSafeArea()
                
                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                case .loaded:
                    shelterListContent
                case .empty:
                    emptyStateView
                case .error(let message):
                    errorStateView(message)
                }
            }
            .navigationTitle("Nearby Shelters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await refreshData() } }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task { await refreshData() }
        }
    }
    
    // MARK: - Content
    
    private var shelterListContent: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Filter chips
            filterChips
            
            // Shelter list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredShelters) { shelter in
                        NavigationLink(destination: ShelterDetailView(shelter: shelter, viewModel: viewModel)) {
                            ShelterCard(shelter: shelter, onRoute: {
                                onSelectShelterForRoute?(shelter)
                            })
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(SafePathColors.textSecondary)
            TextField("Search shelters...", text: $viewModel.searchText)
                .font(SafePathFonts.body)
        }
        .padding(12)
        .background(SafePathColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShelterViewModel.ShelterFilter.allCases, id: \.self) { filter in
                    Button(action: { viewModel.activeFilter = filter }) {
                        Text(filter.rawValue)
                            .font(SafePathFonts.caption)
                            .foregroundColor(viewModel.activeFilter == filter ? .white : SafePathColors.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.activeFilter == filter ? SafePathColors.accentBlue : SafePathColors.cardBackground)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.2)
            Text("Loading shelters...").font(SafePathFonts.body).foregroundColor(SafePathColors.textSecondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 56))
                .foregroundColor(SafePathColors.offlineGray)
            Text("No Shelters Found")
                .font(SafePathFonts.title)
                .foregroundColor(SafePathColors.textPrimary)
            Text("No shelters available in your area.\nTry increasing the search radius.")
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func errorStateView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(SafePathColors.warningOrange)
            Text("Unable to Load Shelters")
                .font(SafePathFonts.title)
            Text(message)
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") { Task { await refreshData() } }
                .font(SafePathFonts.buttonLabel)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(SafePathColors.accentBlue)
                .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    private func refreshData() async {
        if let loc = locationService.currentLocation {
            await viewModel.fetchNearbyShelters(location: loc)
        }
        await viewModel.fetchAllShelters()
    }
}

// MARK: - Shelter Card

struct ShelterCard: View {
    let shelter: Shelter
    var onRoute: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shelter.name)
                        .font(SafePathFonts.headline)
                        .foregroundColor(SafePathColors.textPrimary)
                        .lineLimit(2)
                    
                    if let dist = shelter.distanceKm {
                        Label(dist.distanceDisplay, systemImage: "location.fill")
                            .font(SafePathFonts.caption)
                            .foregroundColor(SafePathColors.accentBlue)
                    }
                }
                
                Spacer()
                
                Text(shelter.shelterType.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(shelter.isOpenArea ? SafePathColors.warningOrange : SafePathColors.accentBlue)
                    .cornerRadius(8)
            }
            
            // Details bar
            HStack {
                Text("Capacity: \(shelter.capacity) people")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.textSecondary)
                Spacer()
                Text("Lv. \(shelter.buildingLevel)")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.textSecondary)
            }
            
            // Facilities
            HStack(spacing: 8) {
                ForEach(shelter.facilities.prefix(4), id: \.self) { facility in
                    Label(Shelter.facilityDisplayName(facility), systemImage: Shelter.facilityIcon(facility))
                        .font(.system(size: 11))
                        .foregroundColor(SafePathColors.textSecondary)
                }
                if shelter.facilities.count > 4 {
                    Text("+\(shelter.facilities.count - 4)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(SafePathColors.accentBlue)
                }
            }
            
            // Buttons
            HStack(spacing: 8) {
                NavigationLink(destination: ShelterDetailView(shelter: shelter, viewModel: viewModel())) {
                    Text("View Detail")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.accentBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(SafePathColors.accentBlue.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: { onRoute?() }) {
                    Label("Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(SafePathColors.accentBlue)
                        .cornerRadius(10)
                }
            }
        }
        .padding(14)
        .safePathCard()
    }
    
    // Quick ViewModel instantiation for detail preview binding
    private func viewModel() -> ShelterViewModel {
        ShelterViewModel()
    }
}


// StatusChip removed to align with updated schema.


// MARK: - Preview

#if DEBUG
struct ShelterListView_Previews: PreviewProvider {
    static var previews: some View {
        ShelterListView()
            .environmentObject(LocationService())
    }
}
#endif
