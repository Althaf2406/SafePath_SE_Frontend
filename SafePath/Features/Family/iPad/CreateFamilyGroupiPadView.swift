import SwiftUI
import Combine

struct CreateFamilyGroupiPadView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var groupName: String = ""
    @State private var inviteCode: String = ""
    @State private var isCodeGenerated: Bool = false
    @State private var showCopiedAlert = false
    @State private var showErrorAlert  = false
    
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Header & Info
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
                        .font(.system(size: 80, weight: .semibold))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .padding(.bottom, 16)
                    
                    Text("Create Family Group")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                    
                    Text("Keep your loved ones safe by creating a private coordination circle.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineSpacing(6)
                }
                
                Spacer()
                
                infoBox
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
            .frame(width: 450)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Right Panel: Form
            VStack(spacing: 40) {
                Spacer()
                
                nameInputCard
                
                invitationCodeCard
                
                Spacer()
            }
            .padding(40)
            .frame(maxWidth: .infinity)
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
        .alert("Failed to Create Group", isPresented: $showErrorAlert) {
            Button("OK") { familyVM.clearError() }
        } message: {
            Text(familyVM.errorMessage ?? "Something went wrong. Please try again.")
        }
        .overlay(Group { if showCopiedAlert { toastOverlay } })
    }
    
    private var nameInputCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Family Group Name")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(SafePathColors.textPrimary)
            
            TextField("e.g. Smith Family", text: $groupName)
                .font(.system(size: 20))
                .padding(20)
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            
            Button(action: {
                guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                Task {
                    await familyVM.createGroup(name: groupName)
                    if let createdGroup = familyVM.familyGroup {
                        inviteCode = createdGroup.inviteCode
                        isCodeGenerated = true
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if var user = userVM.currentUser {
                                if !user.familyGroupIDs.contains(createdGroup.id) {
                                    user.familyGroupIDs.append(createdGroup.id)
                                    userVM.currentUser = user
                                    SessionManager.shared.saveUser(user)
                                }
                            }
                        }
                    } else {
                        showErrorAlert = familyVM.errorMessage != nil
                    }
                }
            }) {
                HStack {
                    if familyVM.isLoading { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
                    Text("Create Group")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(16)
            }
            .disabled(familyVM.isLoading || groupName.isEmpty)
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
    
    private var invitationCodeCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))
                Text("YOUR ACTIVE INVITATION CODE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(SafePathColors.primaryBlue)
            
            VStack(spacing: 24) {
                let spacedCode = inviteCode.map { String($0) }.joined(separator: " ")
                Text(spacedCode.uppercased())
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                    Text("Code expires in 24 hours")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.7))
                
                Button(action: {
                    UIPasteboard.general.string = inviteCode
                    withAnimation { showCopiedAlert = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showCopiedAlert = false }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy Invite Code")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(SafePathColors.lightBlueCard)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
            .background(SafePathColors.accentBlue)
        }
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
    }
    
    private var infoBox: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(SafePathColors.primaryBlue)
                .font(.system(size: 24))
            Text("Only users with this code can join your group. You can manage members and permissions after creation.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SafePathColors.lightBlueCard.opacity(0.6))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
    }
    
    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Code copied to clipboard!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 60)
        }
    }
}
