import SwiftUI
import Combine

struct ProfilePageiPadView: View {
    @Environment(\.dismiss) var dismiss

    @State private var goToEditProfile  = false
    @State private var goToSettings     = false

    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    @StateObject private var emergencyVM = EmergencyStatusViewModel()

    @State private var showLogoutConfirm = false
    @State private var showLogoutToast   = false
    @State private var showLeaveFamilyConfirm = false
    @State private var showStatusOptions = false
    @State private var profileImageData: Data?

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
                VStack(spacing: 32) {
                    // Custom Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(SafePathColors.primaryBlue)
                                .font(.system(size: 24, weight: .semibold))
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    
                    VStack(spacing: 40) {
                        heroBannerSection
                        quickStatsRow
                        menuSection
                        safetyConnectionsSection
                        logoutButton
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $goToEditProfile) { EditProfileiPadView() }
            .navigationDestination(isPresented: $goToSettings) { SettingView() }
            .onAppear {
                if let uid = userVM.currentUser?.id {
                    profileImageData = UserDefaults.standard.data(forKey: "profile_image_\(uid)")
                }
                if let groupID = userVM.currentUser?.familyGroupIDs.first {
                    Task { await familyVM.fetchGroup(groupID: groupID) }
                }
                if let userID = userVM.currentUser?.id {
                    Task { await emergencyVM.fetchStatus(userID: userID) }
                }
            }
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Logout", role: .destructive) {
                    Task { await userVM.logout() }
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
            } message: { Text("You will no longer receive family alerts or location updates.") }
            .confirmationDialog("Update My Status", isPresented: $showStatusOptions, titleVisibility: .visible) {
                Button("Safe", role: .none) { Task { await emergencyVM.updateStatus(status: .safe) } }
                Button("Needs Help", role: .none) { Task { await emergencyVM.updateStatus(status: .needHelp) } }
                Button("SOS — Emergency", role: .destructive) { Task { await emergencyVM.triggerSOS() } }
                Button("Cancel", role: .cancel) {}
            }
            .overlay(Group { if showLogoutToast { toastOverlay } })
        }
    }

    private var heroBannerSection: some View {
        VStack(spacing: 24) {
            ZStack {
                if let data = profileImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 4))
                        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 4))
                        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                    Text(initials)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Circle()
                    .fill(SafePathColors.safeGreen)
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .offset(x: 55, y: 55)
            }
            
            VStack(spacing: 8) {
                Text(userName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(userEmail)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                    Text(userLocation)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [SafePathColors.primaryBlue, SafePathColors.accentBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(30)
        .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 15, y: 10)
    }

    private var quickStatsRow: some View {
        VStack(spacing: 24) {
            // Top Row: My Status (Full width)
            Button(action: { showStatusOptions = true }) {
                let status = emergencyVM.currentStatus?.status ?? .safe
                let iconColor: Color = {
                    if status == .sos { return SafePathColors.dangerRed }
                    if status == .needHelp { return SafePathColors.warningOrange }
                    return SafePathColors.safeGreen
                }()
                let iconName: String = {
                    if status == .safe { return "checkmark.shield.fill" }
                    return "exclamationmark.triangle.fill"
                }()
                statCellBox(
                    value: status.displayName,
                    label: "My Status",
                    icon: iconName,
                    color: iconColor,
                    isHighlight: true
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Bottom Row: Family Members and Family Group
            HStack(spacing: 24) {
                statCellBox(
                    value: familyVM.members.isEmpty ? "-" : "\(familyVM.members.count)",
                    label: "Family Members",
                    icon: "person.2.fill",
                    color: SafePathColors.primaryBlue
                )
                
                statCellBox(
                    value: userVM.currentUser?.familyGroupIDs.isEmpty == false ? "Active" : "None",
                    label: "Family Group",
                    icon: "figure.2.and.child.holdinghands",
                    color: SafePathColors.primaryBlue
                )
            }
        }
    }

    private func statCellBox(value: String, label: String, icon: String, color: Color, isHighlight: Bool = false) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: isHighlight ? 40 : 30))
                .foregroundColor(color)
                .frame(width: isHighlight ? 50 : 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: isHighlight ? 18 : 14, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
                Text(value)
                    .font(.system(size: isHighlight ? 28 : 20, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            Spacer()
        }
        .padding(isHighlight ? 32 : 24)
        .background(Color.white)
        .cornerRadius(isHighlight ? 24 : 20)
        .shadow(color: .black.opacity(isHighlight ? 0.08 : 0.05), radius: isHighlight ? 12 : 8, y: isHighlight ? 6 : 4)
        .overlay(
            RoundedRectangle(cornerRadius: isHighlight ? 24 : 20)
                .stroke(isHighlight ? color.opacity(0.4) : Color.clear, lineWidth: 2)
        )
    }

    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("ACCOUNT")
            VStack(spacing: 0) {
                Button(action: { goToEditProfile = true }) {
                    menuRowContent(icon: "person.fill", iconBg: SafePathColors.primaryBlue.opacity(0.1), iconColor: SafePathColors.primaryBlue, label: "Edit Profile")
                }
                Divider().padding(.leading, 80)
                Button(action: { goToSettings = true }) {
                    menuRowContent(icon: "gearshape.fill", iconBg: Color.gray.opacity(0.1), iconColor: SafePathColors.textSecondary, label: "Settings")
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        }
    }

    private func menuRowContent(icon: String, iconBg: Color, iconColor: Color, label: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 48, height: 48)
                .background(iconBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(label)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(SafePathColors.textSecondary.opacity(0.4))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var safetyConnectionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel("SAFETY CONNECTIONS")
            VStack(spacing: 0) {
                HStack(spacing: 20) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(SafePathColors.dangerRed)
                        .frame(width: 48, height: 48)
                        .background(SafePathColors.dangerRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Emergency Contact")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text(userVM.currentUser?.phone != nil ? "Primary: \(userVM.currentUser!.phone!)" : "No emergency contact set")
                            .font(.system(size: 16))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    Spacer()
                    Button("Manage") {}
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(SafePathColors.primaryBlue.opacity(0.08))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)

                Divider().padding(.leading, 80)

                Button(action: {
                    if userVM.currentUser?.familyGroupIDs.isEmpty == false { showLeaveFamilyConfirm = true }
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 48, height: 48)
                            .background(SafePathColors.primaryBlue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Family Group")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(SafePathColors.textPrimary)
                            let groupName = familyVM.familyGroup?.name ?? (userVM.currentUser?.familyGroupIDs.isEmpty == false ? "Loading..." : "No group yet")
                            let memberCount = familyVM.members.count
                            Text(memberCount > 0 ? "\(groupName) (\(memberCount) Member\(memberCount == 1 ? "" : "s"))" : groupName)
                                .font(.system(size: 16))
                                .foregroundColor(SafePathColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.4))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        }
    }


    private var logoutButton: some View {
        Button(action: { showLogoutConfirm = true }) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                Text("Logout")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(SafePathColors.dangerRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(SafePathColors.dangerRed.opacity(0.5), lineWidth: 2))
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(SafePathColors.textSecondary)
            .tracking(1.2)
            .padding(.leading, 24)
    }

    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Logged out successfully")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(40)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 60)
        }
    }
}
