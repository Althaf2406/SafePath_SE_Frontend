//
//  FamilyDashboardView.swift
//  SafePath
//
//  Created by student on 29/05/26.
//

import SwiftUI

struct FamilyDashboardView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - Hero Image Section (Illustration + Badges)
                    heroSection
                        .padding(.top, 24)
                    
                    // MARK: - Empty State Text
                    VStack(spacing: 12) {
                        Text("No Family Group Yet")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        Text("Create or join a family group to\nshare location and emergency status")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Action Buttons (Routing)
                    VStack(spacing: 16) {
                        // Route ke CreateFamilyGroupView
                        NavigationLink(destination: CreateFamilyGroupView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Create Family Group")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(SafePathColors.primaryBlue)
                            .cornerRadius(14)
                            .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 8, y: 4)
                        }
                        
                        // Route ke JoinFamilyGroupView
                        NavigationLink(destination: JoinFamilyGroupView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Join Family Group")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(SafePathColors.lightBlueCard)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(SafePathColors.primaryBlue.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Removed testing routes
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Privacy Info Card
                    privacyInfoCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    
                }
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews
    
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(SafePathColors.primaryBlue.opacity(0.05))
                .frame(width: 320, height: 320)
                .scaleEffect(1.2)
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .frame(width: 260, height: 220)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "figure.2.and.child.holdinghands")
                            .font(.system(size: 60))
                            .foregroundColor(SafePathColors.primaryBlue.opacity(0.6))
                        Text("Family Group")
                            .font(.caption)
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.5))
                    }
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundColor(SafePathColors.dangerRed)
                Text("Secure")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.dangerRed)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            .offset(x: 100, y: -100)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(SafePathColors.safeGreen)
                    .frame(width: 8, height: 8)
                Text("Live Sync")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            .offset(x: -80, y: 100)
        }
    }
    
    private var privacyInfoCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "shield.fill")
                .font(.system(size: 24))
                .foregroundColor(SafePathColors.primaryBlue.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(SafePathColors.primaryBlue.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Privacy First")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                Text("Your location data is encrypted and only shared with verified group members you approve.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SafePathColors.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SafePathColors.primaryBlue.opacity(0.06))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(SafePathColors.primaryBlue.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    FamilyDashboardView()
}

//ttes
