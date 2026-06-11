//
//  ActiveFamilyDashboardView.swift
//  SafePath
//
//  Created by SafePath on 2026.
//

import SwiftUI
import Combine

struct ActiveFamilyDashboardView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    @State private var showLeaveConfirm = false
    
    // Timer to update relative timestamps (e.g. "Recently") in real-time
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
            VStack(spacing: 24) {
                    
                    // MARK: - Family Header & Invite Code
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text(familyName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(SafePathColors.textPrimary)
                            
                            Text("\(connectedMembers) Members Connected")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(SafePathColors.textSecondary)
                        }
                        
                        // Invite Code Box
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Family Invite Code")
                                    .font(.caption)
                                    .foregroundColor(SafePathColors.textSecondary)
                                Text(inviteCode)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(SafePathColors.primaryBlue)
                            }
                            Spacer()
                            Button(action: {
                                // Copy action here
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(SafePathColors.primaryBlue)
                                    .padding(10)
                                    .background(SafePathColors.primaryBlue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // MARK: - Member Status List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Member Status")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                            .padding(.horizontal, 20)
                        
                        if familyVM.isLoading {
                            ProgressView("Loading members...")
                                .padding()
                        } else if familyVM.members.isEmpty {
                            Text("No members yet.")
                                .font(.system(size: 14))
                                .foregroundColor(SafePathColors.textSecondary)
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(familyVM.members) { member in
                                    HStack(spacing: 16) {
                                        // Profile Avatar
                                        Circle()
                                            .fill(SafePathColors.primaryBlue.opacity(0.1))
                                            .frame(width: 46, height: 46)
                                            .overlay(
                                                Text(String(member.name.prefix(1)))
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(SafePathColors.primaryBlue)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(member.name)
                                                .font(.system(size: 16, weight: .bold))
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
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(statusColor)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.04), radius: 5, y: 2)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Box Buttons for Navigation
                    VStack(spacing: 16) {
                        
                        // SOS Button → langsung ke SOSSentView
                        NavigationLink(destination: SOSSentView()) {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 44))
                                    Text("EMERGENCY SOS")
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .tracking(1.5)
                                }
                                .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 28)
                            .background(
                                LinearGradient(colors: [SafePathColors.dangerRed, Color.red.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(24)
                            .shadow(color: SafePathColors.dangerRed.opacity(0.4), radius: 12, y: 8)
                        }
                        
                        // Secondary Grid Actions
                        HStack(spacing: 16) {
                            NavigationLink(destination: LiveLocationFamilyView()) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: "map.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Live Map")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Track Family")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(SafePathColors.primaryBlue)
                                .cornerRadius(20)
                                .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 8, y: 4)
                            }
                            
                            NavigationLink(destination: FamilyNotificationsView()) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Image(systemName: "bell.badge.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(SafePathColors.primaryBlue)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Alerts")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(SafePathColors.textPrimary)
                                        Text("History")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(SafePathColors.textSecondary)
                                    }
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                            }
                        }
                        
                        // NEW: Leave Family Button
                        Button(action: { showLeaveConfirm = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Leave Family Group")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(SafePathColors.dangerRed)
                            .frame(maxWidth: .infinity)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task {
                    await familyVM.fetchGroup(groupID: groupID)
                }
            }
        }
        .onReceive(timer) { _ in
            timeUpdater = Date()
        }
        .confirmationDialog("Leave Family Group?", isPresented: $showLeaveConfirm, titleVisibility: .visible) {
            Button("Leave Group", role: .destructive) {
                Task {
                    if let groupID = userVM.currentUser?.familyGroupIDs.first {
                        // 1. Tell backend to leave
                        await familyVM.leaveGroup(groupID: groupID)
                        
                        // 2. Remove group locally from session
                        if var user = userVM.currentUser {
                            user.familyGroupIDs.removeAll(where: { $0 == groupID })
                            userVM.currentUser = user
                            SessionManager.shared.saveUser(user)
                        }
                        
                        // AppRouter will automatically detect empty familyGroupIDs and show FamilyDashboardView
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will lose access to family location and alerts.")
        }
    }
    
}

#Preview {
    ActiveFamilyDashboardView()
}

//ttestst
