import SwiftUI

struct FamilyNotificationsiPadView: View {
    @Environment(\.dismiss) var dismiss // Untuk tombol back
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Header / Summary
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    }
                    Spacer()
                }
                .padding(.top, 40)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(SafePathColors.primaryBlue)
                    
                    Text("Family Notifications")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Text("Real-time status updates from your inner circle. Keep track of alerts, emergency statuses, and live location shares.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineSpacing(6)
                }
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
            .frame(width: 400)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Right Panel: Notification List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if familyVM.members.isEmpty {
                        Text("No recent notifications.")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(familyVM.members) { member in
                            let isSafe = member.status == .safe
                            notificationRow(
                                name: member.name,
                                message: isSafe ? "Marked status as " : "Needs help ",
                                status: isSafe ? "Safe." : "immediately.",
                                subMessage: isSafe ? "Last location available" : "Emergency triggered",
                                time: "Recent",
                                color: isSafe ? SafePathColors.safeGreen : SafePathColors.dangerRed,
                                icon: isSafe ? "checkmark.circle.fill" : "mappin.and.ellipse",
                                isCritical: !isSafe
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity)
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
        .onAppear {
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task {
                    await familyVM.fetchGroup(groupID: groupID)
                }
            }
        }
    }
    
    // MARK: - Subviews
    private func notificationRow(name: String, message: String, status: String, subMessage: String, time: String, color: Color, icon: String, isCritical: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 20) {
            ZStack {
                Circle()
                    .fill(isCritical ? color.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                Text(String(name.prefix(1)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isCritical ? color : SafePathColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        HStack(spacing: 0) {
                            Text(message)
                                .foregroundColor(SafePathColors.textPrimary)
                            Text(status)
                                .fontWeight(.bold)
                                .foregroundColor(color)
                        }
                        .font(.system(size: 16))
                    }
                    Spacer()
                    Text(time)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                    Text(subMessage)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(isCritical ? color : SafePathColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isCritical ? color.opacity(0.1) : Color.gray.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
}
