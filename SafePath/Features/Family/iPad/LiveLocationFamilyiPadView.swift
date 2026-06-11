import SwiftUI
import MapKit
import CoreLocation

private struct MapPin: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isCurrentUser: Bool
    let status: FamilyMember.MemberStatus
}

struct LiveLocationFamilyiPadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    @State private var selectedMember: FamilyMember?
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private var allPins: [MapPin] {
        var pins: [MapPin] = []
        
        if let coord = locationService.currentLocation {
            let me = userVM.currentUser
            pins.append(MapPin(
                id: me?.id ?? "me",
                name: "\(me?.name ?? "You") (You)",
                coordinate: coord,
                isCurrentUser: true,
                status: .safe
            ))
        }
        
        for member in familyVM.members {
            if let lat = member.lastLatitude, let lng = member.lastLongitude {
                if member.id == userVM.currentUser?.id { continue }
                pins.append(MapPin(
                    id: member.id,
                    name: member.name,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    isCurrentUser: false,
                    status: member.status
                ))
            }
        }
        return pins
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Member List and Selection
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    }
                    Text("Live Map")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                        .padding(.leading, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(familyVM.members) { member in
                            Button(action: {
                                selectedMember = member
                                if let lat = member.lastLatitude, let lng = member.lastLongitude {
                                    withAnimation {
                                        mapRegion.center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                        mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    }
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(SafePathColors.primaryBlue.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(String(member.name.prefix(1)))
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(SafePathColors.primaryBlue)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.name)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(SafePathColors.textPrimary)
                                        
                                        HStack(spacing: 6) {
                                            let statusColor: Color = {
                                                if member.status == .sos { return SafePathColors.dangerRed }
                                                if member.status == .needHelp { return SafePathColors.warningOrange }
                                                if member.status == .unknown { return Color.gray.opacity(0.5) }
                                                return SafePathColors.safeGreen
                                            }()
                                            Circle()
                                                .fill(statusColor)
                                                .frame(width: 8, height: 8)
                                            Text(member.status == .safe ? "Safe" : member.status == .needHelp ? "Need Help" : member.status == .sos ? "SOS" : member.status == .evacuating ? "Evacuating" : "Offline")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(statusColor)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(selectedMember?.id == member.id ? SafePathColors.primaryBlue.opacity(0.1) : Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.04), radius: 5, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedMember?.id == member.id ? SafePathColors.primaryBlue : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                }
                
                // Details of Selected Member
                if let member = selectedMember {
                    VStack(spacing: 16) {
                        Divider()
                        
                        Text("\(member.name)'s Location")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        if let lat = member.lastLatitude, let lng = member.lastLongitude {
                            Text(String(format: "%.4f, %.4f", lat, lng))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(SafePathColors.textSecondary)
                        } else {
                            Text("Location not available")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SafePathColors.textSecondary)
                        }
                        
                        Button(action: {
                            if let lat = member.lastLatitude, let lng = member.lastLongitude {
                                let dest = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
                                dest.name = member.name
                                dest.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.turn.up.right")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Navigate")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(member.lastLatitude != nil ? SafePathColors.primaryBlue : Color.gray)
                            .cornerRadius(14)
                        }
                        .disabled(member.lastLatitude == nil)
                    }
                    .padding(24)
                    .background(Color.white)
                }
            }
            .frame(width: 400)
            .background(SafePathColors.backgroundLight)
            
            Divider()
            
            // Right Panel: Map
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $mapRegion, annotationItems: allPins) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(pin.isCurrentUser
                                          ? SafePathColors.primaryBlue
                                          : (pin.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed))
                                    .frame(width: 48, height: 48)
                                    .shadow(radius: 4)
                                
                                Image(systemName: pin.isCurrentUser ? "location.fill" : "person.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            
                            Text(pin.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(pin.isCurrentUser
                                            ? SafePathColors.primaryBlue
                                            : (pin.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                        .onTapGesture {
                            if !pin.isCurrentUser, let member = familyVM.members.first(where: { $0.id == pin.id }) {
                                selectedMember = member
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Map Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if let coord = locationService.currentLocation {
                            withAnimation {
                                mapRegion.center = coord
                                mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 24))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                    }
                    
                    Button(action: fitAllPins) {
                        Image(systemName: "square.3.layers.3d")
                            .font(.system(size: 22))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                    }
                }
                .padding(24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let coord = locationService.currentLocation {
                mapRegion.center = coord
            }
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task {
                    await familyVM.fetchFamilyLocations(groupID: groupID)
                }
            }
        }
    }
    
    private func fitAllPins() {
        guard !allPins.isEmpty else { return }
        let lats = allPins.map { $0.coordinate.latitude }
        let lngs = allPins.map { $0.coordinate.longitude }
        let minLat = lats.min()!, maxLat = lats.max()!
        let minLng = lngs.min()!, maxLng = lngs.max()!
        withAnimation {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (minLat + maxLat) / 2,
                    longitude: (minLng + maxLng) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: max((maxLat - minLat) * 1.5, 0.02),
                    longitudeDelta: max((maxLng - minLng) * 1.5, 0.02)
                )
            )
        }
    }
}
