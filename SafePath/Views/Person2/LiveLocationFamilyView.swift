//
//  LiveLocationFamilyView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Identifiable map annotation model

private struct MapPin: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isCurrentUser: Bool
    let status: FamilyMember.MemberStatus
}

struct LiveLocationFamilyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var familyVM = FamilySafetyViewModel()

    @State private var showBottomSheet = false
    @State private var selectedMember: FamilyMember?

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7688),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Combine current user + family members into one list of pins
    private var allPins: [MapPin] {
        var pins: [MapPin] = []

        // Current user pin (from GPS)
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

        // Family member pins (from backend)
        for member in familyVM.members {
            if let lat = member.lastLatitude, let lng = member.lastLongitude {
                // Don't double-render current user if they are in the members list
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
        ZStack(alignment: .bottom) {
            // MARK: - Full-screen Map
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
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 3)
                        )

                        Text(pin.name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(pin.isCurrentUser
                                        ? SafePathColors.primaryBlue
                                        : (pin.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .onTapGesture {
                        // Only family members (not self) can be selected for the detail sheet
                        if !pin.isCurrentUser,
                           let member = familyVM.members.first(where: { $0.id == pin.id }) {
                            selectedMember = member
                            showBottomSheet = true
                        }
                    }
                }
            }
            .ignoresSafeArea()

            // MARK: - Back Button (top-left)
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // MARK: - Floating Action Buttons (top-right)
            VStack(spacing: 12) {
                // Center on my location
                Button(action: {
                    if let coord = locationService.currentLocation {
                        withAnimation {
                            mapRegion.center = coord
                            mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        }
                    }
                }) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                }

                // Fit all pins
                Button(action: fitAllPins) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.system(size: 18))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            .padding(.top, 16)

            // MARK: - Bottom Sheet
            if showBottomSheet, let member = selectedMember {
                memberBottomSheet(member: member)
                    .transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Center on current user GPS
            if let coord = locationService.currentLocation {
                mapRegion.center = coord
            }
            // Fetch family members' last known locations
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task {
                    await familyVM.fetchFamilyLocations(groupID: groupID)
                }
            }
        }
    }

    // MARK: - Helpers

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

    // MARK: - Bottom Sheet

    private func memberBottomSheet(member: FamilyMember) -> some View {
        VStack(spacing: 20) {
            // Handle bar
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            // Close button
            HStack {
                Spacer()
                Button(action: { showBottomSheet = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, -12)

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(member.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(member.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)

                    HStack(spacing: 6) {
                        Circle()
                            .fill(member.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed)
                            .frame(width: 8, height: 8)
                        Text(member.status == .safe ? "SAFE" : member.status == .sos ? "SOS" : member.status == .needHelp ? "NEED HELP" : member.status == .evacuating ? "EVACUATING" : "OFFLINE")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(member.status == .safe ? SafePathColors.safeGreen : SafePathColors.dangerRed)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)

            // Location info
            HStack(spacing: 16) {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(SafePathColors.primaryBlue.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("LAST LOCATION")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                        .tracking(1)
                    if let lat = member.lastLatitude, let lng = member.lastLongitude {
                        Text(String(format: "%.4f, %.4f", lat, lng))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                    } else {
                        Text("Location not available")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(SafePathColors.lightBlueCard)
            .cornerRadius(16)
            .padding(.horizontal, 24)

            // Navigate button
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
                    Text("Navigate to Member")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(member.lastLatitude != nil ? SafePathColors.primaryBlue : Color.gray)
                .cornerRadius(14)
            }
            .disabled(member.lastLatitude == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: -5)
    }
}

#Preview {
    LiveLocationFamilyView()
        .environmentObject(UserManagementViewModel())
        .environmentObject(LocationService())
}
