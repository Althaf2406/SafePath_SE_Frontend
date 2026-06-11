import SwiftUI

struct EmergencyStatusView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // MARK: - Family Identity Header
                familyHeader
                    .padding(.top, 10)

                // MARK: - Giant SOS Trigger
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
                        LinearGradient(
                            colors: [SafePathColors.dangerRed, Color.red.opacity(0.8)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .cornerRadius(24)
                    .shadow(color: SafePathColors.dangerRed.opacity(0.4), radius: 12, y: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // MARK: - Member Status List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Member Status")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                        .padding(.leading, 4)

                    VStack(spacing: 12) {
                        // Current user — selalu tampil di atas
                        memberRow(
                            name: (userVM.currentUser?.name ?? "You") + " (You)",
                            status: "Safe",
                            color: SafePathColors.safeGreen,
                            icon: "checkmark.shield.fill"
                        )
                        // Anggota keluarga lain dari backend
                        ForEach(familyVM.members.filter { $0.id != userVM.currentUser?.id }) { member in
                            memberRow(
                                name: member.name,
                                status: member.status == .safe ? "Safe"
                                      : member.status == .needHelp ? "Need Help"
                                      : member.status == .sos ? "SOS" : "Offline",
                                color: member.isInEmergency ? SafePathColors.dangerRed
                                     : (member.status == .unknown ? .gray : SafePathColors.safeGreen),
                                icon: member.isInEmergency ? "exclamationmark.triangle.fill" : "checkmark.shield.fill",
                                isAlert: member.isInEmergency
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - Navigation Action Boxes
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
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let groupID = userVM.currentUser?.familyGroupIDs.first {
                Task { await familyVM.fetchGroup(groupID: groupID) }
            }
        }
    }

    // MARK: - Subviews

    private var familyHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(familyVM.familyGroup?.name
                     ?? userVM.currentUser?.name.components(separatedBy: " ").first.map { "\($0) Family" }
                     ?? "My Family")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
                Text(familyVM.members.isEmpty
                     ? "Loading members..."
                     : "\(familyVM.members.count) member\(familyVM.members.count == 1 ? "" : "s") connected")
                    .font(.system(size: 14))
                    .foregroundColor(SafePathColors.textSecondary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Family Invite Code")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                    Text(familyVM.familyGroup?.inviteCode ?? "-")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = familyVM.familyGroup?.inviteCode
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .padding(10)
                        .background(SafePathColors.primaryBlue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(20)
            .background(SafePathColors.primaryBlue.opacity(0.05))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.primaryBlue.opacity(0.1), lineWidth: 1))
        }
        .padding(.horizontal, 20)
    }

    private func memberRow(name: String, status: String, color: Color, icon: String, isAlert: Bool = false) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Text(String(name.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                    Text(status)
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(color)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: isAlert ? SafePathColors.dangerRed.opacity(0.1) : Color.black.opacity(0.03), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isAlert ? SafePathColors.dangerRed.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    EmergencyStatusView()
        .environmentObject(UserManagementViewModel())
}
