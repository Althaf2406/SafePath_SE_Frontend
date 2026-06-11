import SwiftUI

struct FamilyDashboardEmptyiPadView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Illustration
            VStack {
                Spacer()
                heroSection
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            
            Divider()
            
            // Right Panel: Actions
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("No Family Group Yet")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Text("Create or join a family group to\nshare location and emergency status")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                
                VStack(spacing: 20) {
                    NavigationLink(destination: CreateFamilyGroupiPadView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 24, weight: .semibold))
                            Text("Create Family Group")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(SafePathColors.primaryBlue)
                        .cornerRadius(16)
                        .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 8, y: 4)
                    }
                    
                    NavigationLink(destination: JoinFamilyGroupiPadView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 24, weight: .semibold))
                            Text("Join Family Group")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(SafePathColors.lightBlueCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(SafePathColors.primaryBlue.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                privacyInfoCard
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(width: 450)
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(SafePathColors.primaryBlue.opacity(0.05))
                .frame(width: 400, height: 400)
                .scaleEffect(1.2)
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                        .frame(width: 320, height: 280)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 80))
                            .foregroundColor(SafePathColors.primaryBlue.opacity(0.6))
                        Text("Family Group")
                            .font(.title3)
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
                    }
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(SafePathColors.dangerRed)
                Text("Secure")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.dangerRed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            .offset(x: 140, y: -120)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(SafePathColors.safeGreen)
                    .frame(width: 12, height: 12)
                Text("Live Sync")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            .offset(x: -120, y: 120)
        }
    }
    
    private var privacyInfoCard: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: "shield.fill")
                .font(.system(size: 30))
                .foregroundColor(SafePathColors.primaryBlue.opacity(0.7))
                .frame(width: 56, height: 56)
                .background(SafePathColors.primaryBlue.opacity(0.1))
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Privacy First")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                Text("Your location data is encrypted and only shared with verified group members you approve.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SafePathColors.primaryBlue.opacity(0.06))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(SafePathColors.primaryBlue.opacity(0.1), lineWidth: 1)
        )
    }
}
