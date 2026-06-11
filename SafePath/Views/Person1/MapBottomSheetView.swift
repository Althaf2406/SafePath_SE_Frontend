import SwiftUI
import Combine

/// Bottom sheet content that adapts between Normal and Emergency mode.
struct MapBottomSheetView: View {
    let selectedShelter: Shelter?
    let currentRoute: EvacuationRoute?
    var alternativeRoutes: [EvacuationRoute] = []
    let isEmergencyMode: Bool
    
    var onSelectShelter: (() -> Void)?
    var onStartRoute: (() -> Void)?
    var onChangeShelter: (() -> Void)?
    var onViewShelterDetail: ((Shelter) -> Void)?
    var onSelectAlternativeRoute: ((Int) -> Void)?
    
    // Person 2 placeholder hooks
    var onShareRouteWithFamily: (() -> Void)?
    var onSOS: (() -> Void)?
    
    // Person 3 placeholder hooks
    var onSaveOffline: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            if isEmergencyMode, let route = currentRoute, let shelter = selectedShelter {
                emergencyRouteSheet(route: route, shelter: shelter)
            } else if let shelter = selectedShelter {
                normalShelterSheet(shelter: shelter)
            } else {
                noSelectionSheet
            }
        }
        .padding(.bottom, 80) // Mencegah konten tertutup oleh tab bar melayang
        .background(SafePathColors.cardBackground)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, y: -3)
    }
    
    // MARK: - Emergency Route Sheet
    
    private func emergencyRouteSheet(route: EvacuationRoute, shelter: Shelter) -> some View {
        VStack(spacing: 14) {
            // Emergency header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text("EVACUATION ROUTE")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(SafePathColors.dangerRed)
            .cornerRadius(10)
            
            // Recommended shelter
            VStack(alignment: .leading, spacing: 6) {
                Text("Recommended Shelter")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.textSecondary)
                Text(shelter.name)
                    .font(SafePathFonts.headline)
                    .foregroundColor(SafePathColors.textPrimary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // ETA / Distance / Safety / Capacity
            HStack(spacing: 0) {
                routeMetric(value: route.etaDisplay, label: "ETA", icon: "clock.fill")
                Divider().frame(height: 40)
                routeMetric(value: route.distanceDisplay, label: "Distance", icon: "location.fill")
                Divider().frame(height: 40)
                routeMetric(value: "\(Int(route.safetyScore * 100))%", label: "Safety", icon: "shield.fill")
                Divider().frame(height: 40)
                routeMetric(value: "\(shelter.capacity)", label: "Cap", icon: "person.3.fill")
            }
            .padding(.vertical, 8)
            .background(SafePathColors.backgroundLight)
            .cornerRadius(12)
            
            // Status
            HStack(spacing: 6) {
                Circle().fill(SafePathColors.safeGreen).frame(width: 8, height: 8)
                Text("Avoiding danger zone")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.safeGreen)
                Spacer()
                Text("Level \(shelter.buildingLevel)")
                    .font(.system(size: 11))
                    .foregroundColor(SafePathColors.textSecondary)
            }
            
            // Facilities
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(shelter.facilities, id: \.self) { facility in
                        Label(Shelter.facilityDisplayName(facility), systemImage: Shelter.facilityIcon(facility))
                            .font(.system(size: 11))
                            .foregroundColor(SafePathColors.accentBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SafePathColors.accentBlue.opacity(0.08))
                            .cornerRadius(16)
                    }
                }
            }
            
            // Buttons
            VStack(spacing: 8) {
                Button(action: { onStartRoute?() }) {
                    Label("Start Navigation", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(SafePathFonts.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(SafePathColors.accentBlue)
                        .cornerRadius(14)
                }
                
                HStack(spacing: 8) {
                    Button(action: { onChangeShelter?() }) {
                        Label("Change", systemImage: "arrow.triangle.swap")
                            .font(SafePathFonts.caption)
                            .foregroundColor(SafePathColors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(SafePathColors.accentBlue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    // Person 2: Share Route
                    Button(action: { onShareRouteWithFamily?() }) {
                        Label("Share", systemImage: "person.2.fill")
                            .font(SafePathFonts.caption)
                            .foregroundColor(SafePathColors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(SafePathColors.accentBlue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    // Person 2: SOS
                    Button(action: { onSOS?() }) {
                        Label("SOS", systemImage: "sos")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(SafePathColors.dangerRed)
                            .cornerRadius(10)
                    }
                }
            }
            
            // Alternative Routes Section
            if !alternativeRoutes.isEmpty {
                alternativeRoutesSection()
            }
        }
        .padding(16)
    }
    
    // MARK: - Alternative Routes
    
    private func alternativeRoutesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Alternative Routes")
                .font(SafePathFonts.caption)
                .foregroundColor(SafePathColors.textSecondary)
                .padding(.top, 8)
            
            ForEach(Array(alternativeRoutes.enumerated()), id: \.offset) { index, route in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Route \(index + 2)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        HStack(spacing: 8) {
                            Label(route.distanceDisplay, systemImage: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SafePathColors.textSecondary)
                            
                            Label(route.etaDisplay, systemImage: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SafePathColors.textSecondary)
                        }
                    }
                    Spacer()
                    
                    Button(action: {
                        onSelectAlternativeRoute?(index)
                    }) {
                        Text("Use This Route")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(SafePathColors.accentBlue)
                            .cornerRadius(8)
                    }
                }
                .padding(12)
                .background(SafePathColors.backgroundLight)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Normal Shelter Sheet
    
    private func normalShelterSheet(shelter: Shelter) -> some View {
        VStack(spacing: 12) {
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
            
            HStack {
                Text("Capacity: \(shelter.capacity) people")
                    .font(SafePathFonts.caption)
                    .foregroundColor(SafePathColors.textSecondary)
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(shelter.facilities.prefix(3), id: \.self) { f in
                            Image(systemName: Shelter.facilityIcon(f))
                                .font(.system(size: 12))
                                .foregroundColor(SafePathColors.accentBlue)
                        }
                    }
                }
                .frame(maxWidth: 80)
            }
            
            HStack(spacing: 8) {
                Button(action: { onViewShelterDetail?(shelter) }) {
                    Text("View Detail")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.accentBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(SafePathColors.accentBlue.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: { onStartRoute?() }) {
                    Label("Preview Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(SafePathColors.accentBlue)
                        .cornerRadius(10)
                }
            }

            
            HStack(spacing: 8) {
                // Person 3 placeholder
                Button(action: { onSaveOffline?() }) {
                    Label("Save Offline", systemImage: "arrow.down.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(SafePathColors.offlineGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(SafePathColors.offlineGray.opacity(0.08))
                        .cornerRadius(8)
                }
                
                // Person 3 placeholder
                Button(action: { onSaveOffline?() }) {
                    Label("Download Map", systemImage: "map.fill")
                        .font(.system(size: 11))
                        .foregroundColor(SafePathColors.offlineGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(SafePathColors.offlineGray.opacity(0.08))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - No Selection
    
    private var noSelectionSheet: some View {
        VStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .font(.title2)
                .foregroundColor(SafePathColors.accentBlue)
            Text("Tap a shelter on the map to see details")
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
    
    // MARK: - Helpers
    
    private func routeMetric(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(SafePathColors.accentBlue)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(SafePathColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#if DEBUG
struct MapBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            MapBottomSheetView(
                selectedShelter: .preview,
                currentRoute: .preview,
                isEmergencyMode: true
            )
        }
        .background(Color.gray.opacity(0.3))
    }
}
#endif
