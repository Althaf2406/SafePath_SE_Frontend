import SwiftUI
import Combine

/// Person 3: First aid guide list and step-by-step display.
struct FirstAidGuideView: View {
    @StateObject private var viewModel = FirstAidGuideViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header Details
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("First Aid Guide")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(SafePathColors.textPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "icloud.and.arrow.down")
                                    .font(.caption)
                                Text("AVAILABLE OFFLINE")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(SafePathColors.safeGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(SafePathColors.safeGreen.opacity(0.15))
                            .cornerRadius(12)
                        }
                        
                        Text("Quick reference guides for emergency medical situations.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(SafePathColors.textSecondary)
                        TextField("Search symptoms or injuries...", text: $viewModel.searchQuery)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                    
                    // Guide List
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredGuides) { guide in
                            NavigationLink(destination: FirstAidGuideDetailView(guide: guide)) {
                                GuideRowView(guide: guide)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
            }
            .background(SafePathColors.backgroundLight.ignoresSafeArea())

        }
    }
}

struct GuideRowView: View {
    let guide: FirstAidGuide
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left color accent bar
            Rectangle()
                .fill(colorForCategory(guide.category))
                .frame(width: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    // Icon
                    Image(systemName: guide.iconName ?? "cross.case.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colorForCategory(guide.category))
                        .frame(width: 40, height: 40)
                        .background(colorForCategory(guide.category).opacity(0.15))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(guide.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    Text(guide.shortDescription)
                        .font(.system(size: 14))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineLimit(2)
                }
                
                Divider()
                
                HStack(spacing: 6) {
                    Image(systemName: "cross.case")
                        .font(.caption)
                        .foregroundColor(SafePathColors.textSecondary)
                    Text("REQUIRED KIT:")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SafePathColors.textSecondary)
                }
                
                Text(guide.requiredKit.map { $0.name }.joined(separator: ", "))
                    .font(.system(size: 13))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            .padding(16)
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "cpr", "bleeding": return SafePathColors.dangerRed
        case "burns": return SafePathColors.warningOrange
        case "fractures", "sprain": return SafePathColors.primaryBlue
        default: return SafePathColors.safeGreen
        }
    }
}
