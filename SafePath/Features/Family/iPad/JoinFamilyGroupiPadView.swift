import SwiftUI
import Combine

struct JoinFamilyGroupiPadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var viewModel = FamilySafetyViewModel()

    @State private var inviteCode: String = ""
    @State private var showError: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Header & Instructions
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
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 80, weight: .medium))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .padding(.bottom, 16)
                    
                    Text("Join Family Group")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                    
                    Text("Stay connected and keep your loved ones safe with real-time updates. Ask your family admin for the invite code.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineSpacing(6)
                }
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 40)
            .frame(width: 450)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Right Panel: Form
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 24) {
                    TextField("E.G. SAFE-1234", text: $inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 32)
                        .background(SafePathColors.primaryBlue.opacity(0.15))
                        .cornerRadius(20)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Button(action: {
                        Task {
                            await viewModel.joinGroup(inviteCode: inviteCode)
                            if viewModel.errorMessage == nil, let joinedGroup = viewModel.familyGroup {
                                if var user = userVM.currentUser {
                                    if !user.familyGroupIDs.contains(joinedGroup.id) {
                                        user.familyGroupIDs.append(joinedGroup.id)
                                        userVM.currentUser = user
                                        SessionManager.shared.saveUser(user)
                                    }
                                }
                                dismiss()
                            } else {
                                showError = true
                            }
                        }
                    }) {
                        ZStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Join Group")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            inviteCode.trimmingCharacters(in: .whitespaces).isEmpty
                                ? SafePathColors.primaryBlue.opacity(0.4)
                                : SafePathColors.primaryBlue
                        )
                        .clipShape(Capsule())
                        .shadow(color: SafePathColors.primaryBlue.opacity(0.25), radius: 8, y: 4)
                    }
                    .disabled(inviteCode.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
                }
                .padding(40)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                
                HStack(spacing: 24) {
                    infoCard(
                        icon: "mappin.circle",
                        iconColor: SafePathColors.primaryBlue,
                        title: "Live Location",
                        subtitle: "See your family on the map."
                    )
                    
                    infoCard(
                        icon: "bell.badge",
                        iconColor: SafePathColors.dangerRed,
                        title: "Smart Alerts",
                        subtitle: "Get notified in emergencies."
                    )
                }
                
                Spacer()
            }
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
        .alert("Failed to Join", isPresented: $showError, actions: {
            Button("OK") {
                viewModel.clearError()
                showError = false
            }
        }, message: {
            Text(viewModel.errorMessage ?? "Something went wrong. Please try again.")
        })
    }
    
    private func infoCard(icon: String, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(iconColor)
                .frame(width: 64, height: 64)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .background(SafePathColors.primaryBlue.opacity(0.1))
        .cornerRadius(24)
    }
}
