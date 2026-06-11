import SwiftUI
import Combine

struct ActiveFamilyDashboardiPadView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    @State private var showLeaveConfirm = false
    @State private var timeUpdater = Date()
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    // Data dinamis dari familyVM
    private var familyName: String {
        familyVM.familyGroup?.name ?? userVM.currentUser?.name.components(separatedBy: " ").first.map { "\($0) Family" } ?? "My Family"
    }
    private var connectedMembers: Int {
        familyVM.members.isEmpty ? 0 : familyVM.members.count
    }
    private var inviteCode: String {
        familyVM.familyGroup?.inviteCode ?? "-"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // MARK: - Header & Action Box (Top area)
                HStack(alignment: .top, spacing: 32) {
                    // Title & Member Count
                    VStack(alignment: .leading, spacing: 8) {
                        Text(familyName)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        Text("\(connectedMembers) Members Connected")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Leave Family Button
                    Button(action: { showLeaveConfirm = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Leave Family Group")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(SafePathColors.dangerRed)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(SafePathColors.dangerRed.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 40)
                
                // MARK: - Invite Code Box
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Family Invite Code")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(SafePathColors.textSecondary)
                        Text(inviteCode)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }
                    Spacer()
                    Button(action: {
                        UIPasteboard.general.string = inviteCode
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 24))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .padding(20)
                            .background(SafePathColors.primaryBlue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(32)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                .padding(.horizontal, 40)
                
                // MARK: - Member List
                VStack(alignment: .leading, spacing: 20) {
                    Text("Member Status")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                        .padding(.leading, 8)
                    
                    if familyVM.isLoading {
                        ProgressView("Loading members...")
                            .padding()
                    } else if familyVM.members.isEmpty {
                        Text("No members yet.")
                            .font(.system(size: 18))
                            .foregroundColor(SafePathColors.textSecondary)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(familyVM.members) { member in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(SafePathColors.primaryBlue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text(String(member.name.prefix(1)))
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundColor(SafePathColors.primaryBlue)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(member.name)
                                            .font(.system(size: 20, weight: .bold))
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
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(statusColor)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                // MARK: - Navigation Action Boxes
                VStack(spacing: 24) {
                    // SOS Button (Full Width / 2 space)
                    NavigationLink(destination: SOSSentView()) {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 48))
                                Text("EMERGENCY SOS")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .tracking(2.0)
                            }
                            .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 40)
                        .background(
                            LinearGradient(colors: [SafePathColors.dangerRed, Color.red.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(24)
                        .shadow(color: SafePathColors.dangerRed.opacity(0.4), radius: 12, y: 8)
                    }
                    
                    // Live Map and Notifications (Side-by-Side)
                    HStack(spacing: 24) {
                        NavigationLink(destination: LiveLocationFamilyView()) {
                            VStack(alignment: .leading, spacing: 16) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Live Map")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("Track Family")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(SafePathColors.primaryBlue)
                            .cornerRadius(20)
                            .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 8, y: 4)
                        }
                        
                        NavigationLink(destination: FamilyNotificationsView()) {
                            VStack(alignment: .leading, spacing: 16) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(SafePathColors.primaryBlue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Alerts")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(SafePathColors.textPrimary)
                                    Text("History")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(SafePathColors.textSecondary)
                                }
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task { await familyVM.fetchGroup(groupID: groupID) }
            }
        }
        .onReceive(timer) { _ in
            timeUpdater = Date()
        }
        .confirmationDialog("Leave Family Group?", isPresented: $showLeaveConfirm, titleVisibility: .visible) {
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
            Text("You will lose access to family location and alerts.")
        }
    }
}
