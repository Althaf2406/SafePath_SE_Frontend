import SwiftUI
import Combine
import MapKit

/// Main map screen with Normal (Shelter Map) and Emergency (Evacuation Map) modes.
struct MainMapView: View {
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var userVM: UserManagementViewModel
    
    @StateObject private var shelterVM = ShelterViewModel()
    @StateObject private var alertVM = DisasterAlertViewModel()
    @StateObject private var routeVM = EvacuationRouteViewModel()
    @StateObject private var familyVM = FamilySafetyViewModel()
    @StateObject private var emergencyVM = EmergencyStatusViewModel()
    
    @State private var isEmergencyMode = false
    @State private var showBottomSheet = true
    @State private var showShelterList = false
    @State private var showShelterDetail = false
    @State private var navigateToShelterDetail: Shelter?
    @State private var centerUserTrigger = false
    @State private var showShareSuccess = false
    @State private var showSOSSuccess = false
    @State private var isNavigating = false
    @State private var showRouteSelectionDialog = false
    @State private var zoomTrigger = 0
    @State private var isZoomIn = true
    
    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen map
            EvacuationMapView(
                userCoordinate: locationService.currentLocation,
                shelters: shelterVM.filteredShelters,
                selectedShelter: shelterVM.selectedShelter,
                alerts: isEmergencyMode ? alertVM.nearbyAlerts : [],
                primaryRoute: routeVM.currentRoute?.mkRoute,
                alternativeRoutes: routeVM.alternativeRoutes.compactMap(\.mkRoute),
                isEmergencyMode: isEmergencyMode,
                centerUserTrigger: centerUserTrigger,
                zoomTrigger: zoomTrigger,
                isZoomIn: isZoomIn,
                isNavigating: isNavigating,
                onShelterTapped: { shelter in
                    if !isNavigating {
                        shelterVM.selectShelter(shelter)
                        showBottomSheet = true
                    }
                }
            )
            .ignoresSafeArea()
            
            // Top overlay controls
            VStack(spacing: 0) {
                if isNavigating {
                    navigationTopBanner
                } else {
                    topBar
                    
                    // Emergency alert banner
                    if isEmergencyMode, let alert = alertVM.nearbyAlerts.first {
                        emergencyBanner(alert)
                    }
                }
                
                Spacer()
            }
            
            // Bottom sheet or Navigation HUD
            VStack {
                Spacer()
                
                if isNavigating {
                    navigationBottomHUD
                        .transition(.move(edge: .bottom))
                } else if showBottomSheet {
                    MapBottomSheetView(
                        selectedShelter: shelterVM.selectedShelter,
                        currentRoute: routeVM.currentRoute,
                        alternativeRoutes: routeVM.alternativeRoutes,
                        isEmergencyMode: isEmergencyMode,
                        onSelectShelter: {
                            if let shelter = shelterVM.selectedShelter, let loc = locationService.currentLocation {
                                Task { await routeVM.calculateRoute(from: loc, to: shelter) }
                            }
                        },
                        onStartRoute: {
                            withAnimation(.easeInOut) {
                                isNavigating = true
                                showBottomSheet = false
                            }
                        },
                        onChangeShelter: {
                            showShelterList = true
                        },
                        onViewShelterDetail: { shelter in
                            navigateToShelterDetail = shelter
                            showShelterDetail = true
                        },
                        onSelectAlternativeRoute: { index in
                            routeVM.selectRoute(at: index)
                        },
                        onShareRouteWithFamily: {
                            // Person 2 placeholder
                            if let route = routeVM.currentRoute {
                                routeVM.onShareRoute?(route)
                            }
                        },
                        onSOS: {
                            // Person 2 placeholder
                            routeVM.onSOS?()
                        },
                        onSaveOffline: {
                            // Person 3 placeholder
                            if let route = routeVM.currentRoute {
                                routeVM.onSaveRouteOffline?(route)
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Floating buttons (right side)
            if !isNavigating {
                VStack {
                    Spacer()
                        .frame(height: 160)
                    
                    VStack(spacing: 10) {
                        // Find nearest shelter
                        floatingButton(icon: "building.2.fill", label: "Nearest") {
                            if let nearest = shelterVM.findNearestAvailable(preferMedical: isEmergencyMode) {
                                shelterVM.selectShelter(nearest)
                                if let loc = locationService.currentLocation {
                                    Task { await routeVM.calculateRoute(from: loc, to: nearest) }
                                }
                            }
                        }
                        
                        // My location
                        floatingButton(icon: "location.fill", label: "Location") {
                            locationService.startUpdating()
                            centerUserTrigger.toggle()
                        }
                        
                        // Toggle bottom sheet
                        floatingButton(icon: showBottomSheet ? "chevron.down" : "chevron.up", label: "Sheet") {
                            withAnimation(.spring()) {
                                showBottomSheet.toggle()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)
            }
            
            // Zoom Controls
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Button(action: {
                        isZoomIn = true
                        zoomTrigger += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(SafePathColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                    }
                    
                    Divider().frame(width: 44)
                    
                    Button(action: {
                        isZoomIn = false
                        zoomTrigger += 1
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(SafePathColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                    }
                }
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                Spacer().frame(height: isNavigating ? 180 : 320)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            
            // Route calculating overlay
            if routeVM.isCalculating {
                calculatingOverlay
            }
        }
        .sheet(isPresented: $showShelterList) {
            ShelterListView(onSelectShelterForRoute: { shelter in
                shelterVM.selectShelter(shelter)
                showShelterList = false
                if let loc = locationService.currentLocation {
                    Task { await routeVM.calculateRoute(from: loc, to: shelter) }
                }
            })
            .environmentObject(locationService)
        }
        .sheet(isPresented: $showShelterDetail) {
            if let shelter = navigateToShelterDetail {
                NavigationStack {
                    ShelterDetailView(shelter: shelter, viewModel: shelterVM)
                }
            }
        }
        .task {
            locationService.requestPermission()
            alertVM.requestNotificationPermission()
            
            // Inisialisasi callback rute untuk integrasi keluarga (Person 2)
            routeVM.onShareRoute = { route in
                print("📢 Route shared: \(route.shelterName)")
                if let loc = locationService.currentLocation {
                    Task {
                        await familyVM.shareLocation(latitude: loc.latitude, longitude: loc.longitude)
                        if let currentUserId = userVM.currentUser?.id {
                            await familyVM.updateMemberStatus(memberID: currentUserId, status: .evacuating)
                        }
                        await emergencyVM.updateStatus(
                            status: .evacuating,
                            message: "Started evacuation route to \(route.shelterName)",
                            latitude: loc.latitude,
                            longitude: loc.longitude
                        )
                        showShareSuccess = true
                    }
                } else {
                    Task {
                        if let currentUserId = userVM.currentUser?.id {
                            await familyVM.updateMemberStatus(memberID: currentUserId, status: .evacuating)
                        }
                        await emergencyVM.updateStatus(
                            status: .evacuating,
                            message: "Started evacuation route to \(route.shelterName)"
                        )
                        showShareSuccess = true
                    }
                }
            }
            
            routeVM.onSOS = {
                print("🚨 SOS button pressed on Map!")
                if let loc = locationService.currentLocation {
                    Task {
                        await emergencyVM.triggerSOS(latitude: loc.latitude, longitude: loc.longitude)
                        showSOSSuccess = true
                    }
                } else {
                    Task {
                        await emergencyVM.triggerSOS()
                        showSOSSuccess = true
                    }
                }
            }
            
            // Fetch initial data
            await shelterVM.fetchAllShelters()
            await alertVM.fetchAllAlerts()
            
            if let loc = locationService.currentLocation {
                await shelterVM.fetchNearbyShelters(location: loc)
                await alertVM.fetchNearbyAlerts(location: loc)
                
                // Auto-enable emergency mode if critical alerts nearby
                let nearbyCritical = alertVM.nearbyAlerts.filter { $0.severity == .critical }
                if !nearbyCritical.isEmpty {
                    withAnimation { isEmergencyMode = true }
                    
                    // Auto-find nearest shelter
                    if let nearest = shelterVM.findNearestAvailable(preferMedical: true) {
                        shelterVM.selectShelter(nearest)
                        await routeVM.calculateRoute(from: loc, to: nearest)
                    }
                }
            }
        }
        .onChange(of: locationService.currentLocation?.latitude) { oldValue, newValue in
            if let loc = locationService.currentLocation {
                Task {
                    await shelterVM.fetchNearbyShelters(location: loc)
                    await alertVM.fetchNearbyAlerts(location: loc)
                    
                    // Auto-enable or disable emergency mode based on nearby critical alerts
                    let nearbyCritical = alertVM.nearbyAlerts.filter { $0.severity == .critical }
                    withAnimation {
                        isEmergencyMode = !nearbyCritical.isEmpty
                    }
                }
                
                if let shelter = shelterVM.selectedShelter {
                    Task { await routeVM.recalculateIfNeeded(newLocation: loc, shelter: shelter) }
                }
            }
        }
        .alert("Route Shared", isPresented: $showShareSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Informasi rute evakuasi Anda ke shelter telah berhasil dibagikan dengan grup keluarga Anda.")
        }
        .alert("SOS Emergency Sent", isPresented: $showSOSSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sinyal darurat SOS telah diaktifkan dan dikirim ke seluruh anggota keluarga Anda.")
        }
        .confirmationDialog("Pilih Rute Alternatif", isPresented: $showRouteSelectionDialog, titleVisibility: .visible) {
            ForEach(Array(routeVM.alternativeRoutes.enumerated()), id: \.offset) { index, route in
                Button("Rute \(index + 2) (\(route.etaDisplay), \(route.distanceDisplay))") {
                    routeVM.selectRoute(at: index)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Pilih rute evakuasi lain jika jalur saat ini terhambat.")
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack(spacing: 12) {
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(isEmergencyMode ? "Evacuation Map" : "Shelter Map")
                    .font(SafePathFonts.headline)
                    .foregroundColor(SafePathColors.textPrimary)
            }
            
            Spacer()
            
            // Mode chip
            modeChip
            
            // Shelter list button
            Button(action: { showShelterList = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SafePathColors.textPrimary)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Mode Toggle Chip
    
    private var modeChip: some View {
        Button(action: {
            withAnimation(.spring()) { isEmergencyMode.toggle() }
            
            if isEmergencyMode {
                // Enter emergency: find nearest shelter and route
                if let loc = locationService.currentLocation,
                   let nearest = shelterVM.findNearestAvailable(preferMedical: true) {
                    shelterVM.selectShelter(nearest)
                    Task { await routeVM.calculateRoute(from: loc, to: nearest) }
                }
            } else {
                routeVM.clearRoute()
            }
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(isEmergencyMode ? SafePathColors.dangerRed : SafePathColors.safeGreen)
                    .frame(width: 8, height: 8)
                Text(isEmergencyMode ? "Emergency" : "Normal")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(isEmergencyMode ? SafePathColors.dangerRed : SafePathColors.safeGreen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isEmergencyMode
                    ? SafePathColors.dangerRed.opacity(0.12)
                    : SafePathColors.safeGreen.opacity(0.12)
            )
            .cornerRadius(20)
        }
    }
    
    // MARK: - Emergency Banner
    
    private func emergencyBanner(_ alert: DisasterAlert) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(alert.typeDisplayName) — M\(String(format: "%.1f", alert.magnitude))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(alert.locationName)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            Spacer()
            if let dist = alert.distanceKm {
                Text(dist.distanceDisplay)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(SafePathColors.dangerRed)
    }
    
    // MARK: - Floating Button
    
    private func floatingButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(SafePathColors.primaryBlue)
            .frame(width: 52, height: 52)
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        }
    }
    
    // MARK: - Calculating Overlay
    
    private var calculatingOverlay: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)
            Text("Calculating route...")
                .font(SafePathFonts.caption)
                .foregroundColor(.white)
        }
        .padding(24)
        .background(Color.black.opacity(0.6))
        .cornerRadius(16)
    }
    
    // MARK: - Navigation Views (Google Maps Style)
    
    private var navigationTopBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 16) {
                // Turn-by-turn arrow
                Image(systemName: "arrow.up")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let shelter = shelterVM.selectedShelter {
                        Text("Menuju \(shelter.name)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    } else {
                        Text("Ke arah barat")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Kemudian ikuti rute evakuasi aman")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Compass / Location North Icon
                Image(systemName: "location.north.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(red: 0.0, green: 0.35, blue: 0.3)) // Dark teal green
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .shadow(color: Color.black.opacity(0.15), radius: 8, y: 4)
    }
    
    private var navigationBottomHUD: some View {
        HStack {
            // Exit Button
            Button(action: {
                withAnimation(.easeInOut) {
                    isNavigating = false
                    showBottomSheet = true
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
            }
            
            Spacer()
            
            // Route ETA & Distance
            if let route = routeVM.currentRoute {
                VStack(spacing: 3) {
                    HStack(spacing: 6) {
                        Text(route.etaDisplay)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(SafePathColors.safeGreen)
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 13))
                            .foregroundColor(SafePathColors.safeGreen)
                    }
                    
                    HStack(spacing: 5) {
                        Text(route.distanceDisplay)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(SafePathColors.textSecondary)
                        Text("•")
                            .foregroundColor(SafePathColors.textSecondary)
                        Text(getArrivalTime(etaString: route.etaDisplay))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                }
            } else {
                Text("Navigating...")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: 12) {
                if !routeVM.alternativeRoutes.isEmpty {
                    Button(action: {
                        showRouteSelectionDialog = true
                    }) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(SafePathColors.primaryBlue)
                            .clipShape(Circle())
                            .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 4, y: 2)
                    }
                }
                
                Button(action: {
                    centerUserTrigger.toggle()
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(SafePathColors.accentBlue)
                        .clipShape(Circle())
                        .shadow(color: SafePathColors.accentBlue.opacity(0.3), radius: 4, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: -3)
        .padding(.horizontal, 16)
        .padding(.bottom, 90) // Mencegah HUD navigasi tertutup oleh tab bar melayang
    }
    
    // Helper to calculate arrival time
    private func getArrivalTime(etaString: String) -> String {
        let cleanString = etaString.lowercased()
        var totalMinutes = 0
        
        if cleanString.contains("hr") {
            let components = cleanString.components(separatedBy: "hr")
            if let hr = Int(components[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                totalMinutes += hr * 60
            }
            if components.count > 1 && components[1].contains("min") {
                let minPart = components[1].components(separatedBy: "min")[0]
                if let min = Int(minPart.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    totalMinutes += min
                }
            }
        } else if cleanString.contains("min") {
            let cleanStringComponents = cleanString.components(separatedBy: "min")
            if !cleanStringComponents.isEmpty, let min = Int(cleanStringComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
                totalMinutes += min
            }
        } else {
            totalMinutes = 15
        }
        
        let arrivalDate = Date().addingTimeInterval(TimeInterval(totalMinutes * 60))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter.string(from: arrivalDate)
    }
}

// MARK: - Preview

#if DEBUG
struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
            .environmentObject(LocationService())
            .environmentObject(UserManagementViewModel())
    }
}
#endif
