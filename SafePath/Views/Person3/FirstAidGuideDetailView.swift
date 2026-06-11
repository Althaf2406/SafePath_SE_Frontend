import SwiftUI

struct FirstAidGuideDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    let guide: FirstAidGuide
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header details
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("OFFLINE AVAILABLE")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(SafePathColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                
                Text(guide.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        let phone = userVM.currentUser?.phone ?? "911"
                        if let url = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "staroflife.fill")
                            Text("Call Emergency Contact")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(SafePathColors.dangerRed)
                        .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: MainMapView()) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Find Shelter")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(SafePathColors.primaryBlue)
                        .cornerRadius(12)
                    }
                }
                
                // Kit List
                if !guide.requiredKit.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Required Kit List")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(guide.requiredKit) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("•")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(SafePathColors.textPrimary)
                                    Text(item.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(SafePathColors.textPrimary)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 20) {
                    Text("Instructions")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                        .padding(.top, 10)
                    
                    ForEach(Array(guide.detailedSteps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 16) {
                            // Number circle
                            Text("\(index + 1)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(SafePathColors.primaryBlue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(step.title)
                                    .font(.system(size: 16, weight: .bold))
                                    // Highlight title if it says "Do not"
                                    .foregroundColor(step.title.lowercased().contains("do not") ? SafePathColors.dangerRed : SafePathColors.textPrimary)
                                
                                Text(step.description)
                                    .font(.system(size: 15))
                                    .foregroundColor(SafePathColors.textSecondary)
                                    .lineSpacing(4)
                            }
                        }
                    }
                }
                .padding(.top, 8)
                
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("First Aid")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
            }
        }
    }
}
