import SwiftUI

struct FamilyNotificationsView: View {
    @Environment(\.dismiss) var dismiss // Untuk tombol back
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    @StateObject private var emergencyVM = EmergencyStatusViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Top Bar
            customNavigationBar
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Family Notifications")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Real-time status updates from your inner circle.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // MARK: - Notification List
                    VStack(spacing: 16) {
                        if emergencyVM.familyStatuses.isEmpty {
                            Text("No recent notifications.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(SafePathColors.textSecondary)
                                .padding(.top, 20)
                        } else {
                            ForEach(emergencyVM.familyStatuses) { statusLog in
                                let config = notificationConfig(for: statusLog.status)
                                
                                // Map EmergencyStatusType to FamilyMember.MemberStatus equivalent to reuse notificationConfig
                                // Wait, they are basically the same raw values. Let's create an adapter if needed, or just change notificationConfig
                                
                                notificationRow(
                                    name: statusLog.userName ?? "Unknown Member",
                                    message: config.message,
                                    status: config.status,
                                    subMessage: statusLog.message ?? config.subMessage,
                                    time: timeAgo(from: statusLog.updatedAt),
                                    color: config.color,
                                    icon: config.icon,
                                    isCritical: config.isCritical
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task {
                    await familyVM.fetchGroup(groupID: groupID)
                    await emergencyVM.fetchFamilyStatuses(groupID: groupID)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
    }
    
    private func notificationRow(name: String, message: String, status: String, subMessage: String, time: String, color: Color, icon: String, isCritical: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCritical ? color.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                Text(String(name.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isCritical ? color : SafePathColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        HStack(spacing: 0) {
                            Text(message)
                                .foregroundColor(SafePathColors.textPrimary)
                            Text(status)
                                .fontWeight(.bold)
                                .foregroundColor(color)
                        }
                        .font(.system(size: 14))
                    }
                    Spacer()
                    Text(time)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                    Text(subMessage)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(isCritical ? color : SafePathColors.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isCritical ? color.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
    }
    
    // MARK: - Status Mapping Helper
    
    private func notificationConfig(for status: EmergencyStatus.EmergencyStatusType) -> (message: String, status: String, subMessage: String, color: Color, icon: String, isCritical: Bool) {
        switch status {
        case .safe:
            return ("Marked status as ", "Safe.", "Last location available", SafePathColors.safeGreen, "checkmark.circle.fill", false)
        case .evacuating:
            return ("Started an ", "Evacuation Route.", "Navigating to shelter", SafePathColors.primaryBlue, "arrow.triangle.turn.up.right.circle.fill", false)
        case .needHelp:
            return ("Needs help ", "soon.", "Please check on them", SafePathColors.warningOrange, "exclamationmark.circle.fill", true)
        case .sos:
            return ("Needs help ", "immediately.", "Emergency triggered", SafePathColors.dangerRed, "mappin.and.ellipse", true)
        case .unknown:
            return ("Status is ", "Unknown.", "Location unavailable", SafePathColors.textSecondary, "questionmark.circle.fill", false)
        }
    }
    
    // Formatter for relative time
    private func timeAgo(from date: Date?) -> String {
        guard let date = date else { return "Recent" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview{
    FamilyNotificationsView()
        .environmentObject(UserManagementViewModel())
}


//tetes
