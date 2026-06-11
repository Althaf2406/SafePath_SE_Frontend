//
//  ProfilePageView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI
import Combine

/// Person 2: Profile page — premium redesign matching Figma page 34.
struct ProfilePageView: View {
    @Environment(\.dismiss) var dismiss

    // MARK: - Navigation States
    @State private var goToEditProfile  = false
    @State private var goToSettings     = false

    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    @StateObject private var emergencyVM = EmergencyStatusViewModel()

    // MARK: - UI States
    @State private var showLogoutConfirm = false
    @State private var showLogoutToast   = false
    @State private var showLeaveFamilyConfirm = false
    @State private var showStatusOptions = false
    @State private var profileImageData: Data?

    // Computed properties mapped to UserManagementViewModel
    private var userName: String { userVM.currentUser?.name ?? "" }
    private var userEmail: String { userVM.currentUser?.email ?? "" }
    private var userLocation: String {
        if let lat = userVM.currentUser?.lastLatitude, let lon = userVM.currentUser?.lastLongitude {
            return String(format: "%.4f, %.4f", lat, lon)
        }
        return "Location not set"
    }
    private var initials: String {
        let name = userVM.currentUser?.name ?? ""
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Hero Banner + Avatar
                    heroBannerSection
                        .padding(.bottom, 24)

                    // MARK: - Quick Stats Row
                    quickStatsRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                    // MARK: - Account Menu Card
                    menuSection

                    // MARK: - Safety Connections
                    safetyConnectionsSection
                        .padding(.top, 24)

                    // MARK: - Device Status
                    deviceStatusSection
                        .padding(.top, 24)

                    // MARK: - Logout Button
                    logoutButton
                        .padding(.horizontal, 16)
                        .padding(.top, 28)
                    
                    // MARK: - Debug Watch SOS
                    debugWatchSOSButton
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                }
            }
            .background(SafePathColors.backgroundLight.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(SafePathColors.primaryBlue)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(SafePathColors.primaryBlue)
                            .font(.system(size: 16, weight: .bold))
                        Text("SafePath")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }
                }
            }
            // MARK: - Navigation Destinations
            .navigationDestination(isPresented: $goToEditProfile) {
                EditProfileView()
            }
            .navigationDestination(isPresented: $goToSettings) {
                SettingView()
            }
            .onAppear {
                if let uid = userVM.currentUser?.id {
                    profileImageData = UserDefaults.standard.data(forKey: "profile_image_\(uid)")
                }
                // Fetch family data jika user sudah punya group
                if let groupID = userVM.currentUser?.familyGroupIDs.first {
                    Task {
                        await familyVM.fetchGroup(groupID: groupID)
                    }
                }
                if let userID = userVM.currentUser?.id {
                    Task {
                        await emergencyVM.fetchStatus(userID: userID)
                    }
                }
            }
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Logout", role: .destructive) {
                    Task {
                        await userVM.logout()
                    }
                    withAnimation { showLogoutToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showLogoutToast = false }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .confirmationDialog("Leave Family Group?", isPresented: $showLeaveFamilyConfirm, titleVisibility: .visible) {
                Button("Leave Group", role: .destructive) {
                    Task {
                        if let groupID = userVM.currentUser?.familyGroupIDs.first {
                            await familyVM.leaveGroup(groupID: groupID)
                            if var user = userVM.currentUser {
                                user.familyGroupIDs.removeAll(where: { $0 == groupID })
                                userVM.currentUser = user
                                SessionManager.shared.saveUser(user)
                            }
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will no longer receive family alerts or location updates.")
            }
            .confirmationDialog("Update My Status", isPresented: $showStatusOptions, titleVisibility: .visible) {
                Button("Safe", role: .none) {
                    Task { await emergencyVM.updateStatus(status: .safe) }
                }
                Button("Needs Help", role: .none) {
                    Task { await emergencyVM.updateStatus(status: .needHelp) }
                }
                Button("SOS — Emergency", role: .destructive) {
                    Task { await emergencyVM.triggerSOS() }
                }
                Button("Cancel", role: .cancel) {}
            }
            .overlay(
                Group { if showLogoutToast { toastOverlay } }
            )
        }
    }

    // MARK: - Hero Banner + Avatar

    private var heroBannerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient Banner
            LinearGradient(
                colors: [SafePathColors.primaryBlue, SafePathColors.accentBlue.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            // Decorative Circles
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 180, height: 180)
                .offset(x: -40, y: 60)
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 120, height: 120)
                .offset(x: UIScreen.main.bounds.width - 80, y: 20)

            // Avatar + Info
            HStack(alignment: .bottom, spacing: 16) {
                // Avatar Circle with Initials or Photo
                ZStack {
                    if let data = profileImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 88, height: 88)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                        Text(initials)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }

                    // Online badge
                    Circle()
                        .fill(SafePathColors.safeGreen)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                        .offset(x: 30, y: 30)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(userEmail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(userLocation)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.65))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // MARK: - Quick Stats Row

    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            statCell(
                value: familyVM.members.isEmpty ? "-" : "\(familyVM.members.count)",
                label: "Family Members",
                icon: "person.2.fill",
                color: SafePathColors.primaryBlue
            )
            Divider().frame(height: 40)
            
            Button(action: { showStatusOptions = true }) {
                statCell(
                    value: emergencyVM.currentStatus?.status.displayName ?? "Safe",
                    label: "My Status",
                    icon: emergencyVM.currentStatus?.status == .safe ? "checkmark.shield.fill" : "exclamationmark.triangle.fill",
                    color: (emergencyVM.currentStatus?.status == .safe || emergencyVM.currentStatus == nil) ? SafePathColors.safeGreen : SafePathColors.dangerRed
                )
            }
            
            Divider().frame(height: 40)
            statCell(value: userVM.currentUser?.familyGroupIDs.isEmpty == false ? "Active" : "None", label: "Family Group", icon: "figure.2.and.child.holdinghands", color: SafePathColors.primaryBlue)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.textPrimary)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(SafePathColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Account Menu Card

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("ACCOUNT")

            VStack(spacing: 0) {
                // Edit Profile — uses @State navigation to avoid toolbar conflict
                Button(action: { goToEditProfile = true }) {
                    menuRowContent(
                        icon: "person.fill",
                        iconBg: SafePathColors.primaryBlue.opacity(0.1),
                        iconColor: SafePathColors.primaryBlue,
                        label: "Edit Profile"
                    )
                }

                Divider().padding(.leading, 60)

                // Settings — uses @State navigation
                Button(action: { goToSettings = true }) {
                    menuRowContent(
                        icon: "gearshape.fill",
                        iconBg: Color.gray.opacity(0.1),
                        iconColor: SafePathColors.textSecondary,
                        label: "Settings"
                    )
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .padding(.horizontal, 16)
    }

    private func menuRowContent(icon: String, iconBg: Color, iconColor: Color, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(SafePathColors.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }

    // MARK: - Safety Connections Section

    private var safetyConnectionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("SAFETY CONNECTIONS")

            VStack(spacing: 0) {
                // Emergency Contact
                HStack(spacing: 14) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(SafePathColors.dangerRed)
                        .frame(width: 32, height: 32)
                        .background(SafePathColors.dangerRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Emergency Contact")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text(userVM.currentUser?.phone != nil ? "Primary: \(userVM.currentUser!.phone!)" : "No emergency contact set")
                            .font(.system(size: 13))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    Spacer()
                    Button("Manage") {}
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SafePathColors.primaryBlue.opacity(0.08))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider().padding(.leading, 62)

                // Family Group
                Button(action: {
                    if userVM.currentUser?.familyGroupIDs.isEmpty == false {
                        showLeaveFamilyConfirm = true
                    }
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 32, height: 32)
                            .background(SafePathColors.primaryBlue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Family Group")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(SafePathColors.textPrimary)
                            let groupName = familyVM.familyGroup?.name ?? (userVM.currentUser?.familyGroupIDs.isEmpty == false ? "Loading..." : "No group yet")
                            let memberCount = familyVM.members.count
                            Text(memberCount > 0 ? "\(groupName) (\(memberCount) Member\(memberCount == 1 ? "" : "s"))" : groupName)
                                .font(.system(size: 13))
                                .foregroundColor(SafePathColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.4))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Device Status Section

    private var deviceStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("DEVICE STATUS")

            VStack(spacing: 0) {
                deviceRow(icon: "iphone",     label: "iPhone",  status: "Active")
                Divider().padding(.leading, 62)
                deviceRow(icon: "ipad",       label: "iPad",    status: "Active")
                Divider().padding(.leading, 62)
                deviceRow(icon: "applewatch", label: "Watch",   status: "Active")
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        }
        .padding(.horizontal, 16)
    }

    private func deviceRow(icon: String, label: String, status: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(SafePathColors.textPrimary)
                .frame(width: 32)
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(SafePathColors.safeGreen)
                    .frame(width: 6, height: 6)
                Text(status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SafePathColors.safeGreen)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button(action: { showLogoutConfirm = true }) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Logout")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(SafePathColors.dangerRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(SafePathColors.dangerRed.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        }
    }
    
    // MARK: - Debug Button
    
    private var debugWatchSOSButton: some View {
        Button(action: {
            NotificationCenter.default.post(name: Notification.Name("WatchDidTriggerSOS"), object: nil)
            showLogoutToast = true // Reusing toast for feedback
        }) {
            HStack(spacing: 10) {
                Image(systemName: "applewatch.radiowaves.left.and.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Simulate Watch SOS (Debug)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(SafePathColors.warningOrange)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(SafePathColors.textSecondary)
            .tracking(0.8)
            .padding(.leading, 20)
    }

    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Logged out successfully")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePageView()
            .environmentObject(UserManagementViewModel())
    }
}

//tetst
