import SwiftUI
import Combine

/// Person 2: Create Family Group view matching the visual style in Screenshot 1.
struct CreateFamilyGroupView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var groupName: String = ""
    @State private var inviteCode: String = ""
    @State private var isCodeGenerated: Bool = false
    @State private var showCopiedAlert = false
    @State private var showErrorAlert  = false
    
    @EnvironmentObject var userVM: UserManagementViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Icon & Subtitles
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(width: 80, height: 80)
                        .background(SafePathColors.lightBlueCard)
                        .clipShape(Circle())
                        .padding(.top, 16)
                    
                    Text("Create Family Group")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                    
                    Text("Keep your loved ones safe by creating a private coordination circle.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Group Name Creation Card
                nameInputCard
                
                // Active Invitation Code Card
                invitationCodeCard
                
                // Info Box at Bottom
                infoBox
                
                // Requirements fulfilled
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
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
                Text("SafePath")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
        }
        .alert("Failed to Create Group", isPresented: $showErrorAlert) {
            Button("OK") { familyVM.clearError() }
        } message: {
            Text(familyVM.errorMessage ?? "Something went wrong. Please try again.")
        }
        .overlay(
            Group {
                if showCopiedAlert {
                    toastOverlay
                }
            }
        )
    }
    
    // MARK: - Name Input Card
    private var nameInputCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Family Group Name")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(SafePathColors.textPrimary)
            
            TextField("e.g. Smith Family", text: $groupName)
                .padding()
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                )
            
            Button(action: {
                guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                Task {
                    await familyVM.createGroup(name: groupName)

                    if let createdGroup = familyVM.familyGroup {
                        // Tampilkan invite code yang baru dibuat
                        inviteCode      = createdGroup.inviteCode
                        isCodeGenerated = true

                        // Tunggu 2 detik agar user sempat lihat invite code
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        
                        // Tutup layar (kembali ke FamilyDashboardView) terlebih dahulu
                        dismiss()
                        
                        // Update userVM setelah layar ditutup agar AppRouter aman saat melakukan switch ke EmergencyStatusView
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
                        // Ada error yang ditangkap (seharusnya tidak terjadi karena ada mock)
                        showErrorAlert = familyVM.errorMessage != nil
                    }
                }
            }) {
                HStack {
                    if familyVM.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("Create Group")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(12)
            }
            .disabled(familyVM.isLoading || groupName.isEmpty)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Invitation Code Card
    private var invitationCodeCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                Text("YOUR ACTIVE INVITATION CODE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(SafePathColors.primaryBlue)
            
            VStack(spacing: 16) {
                // Display Code
                let spacedCode = inviteCode.map { String($0) }.joined(separator: " ")
                Text(spacedCode.uppercased())
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                
                // Expiry timer
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("Code expires in 24 hours")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.7))
                
                // Copy Button
                Button(action: {
                    UIPasteboard.general.string = inviteCode
                    withAnimation {
                        showCopiedAlert = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showCopiedAlert = false
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy Invite Code")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(SafePathColors.lightBlueCard)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(SafePathColors.accentBlue)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Info Box
    private var infoBox: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(SafePathColors.primaryBlue)
                .font(.headline)
            
            Text("Only users with this code can join your group. You can manage members and permissions after creation.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SafePathColors.lightBlueCard.opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
        )
    }
    
    // MARK: - Toast Overlay
    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Code copied to clipboard!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        CreateFamilyGroupView()
            .environmentObject(UserManagementViewModel())
    }
}

//tetststs
