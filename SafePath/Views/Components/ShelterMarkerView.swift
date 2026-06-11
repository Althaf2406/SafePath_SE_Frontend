import SwiftUI
import Combine

/// Color-coded shelter marker for SwiftUI context (non-map usage like lists or previews).
struct ShelterMarkerView: View {
    let shelter: Shelter
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .shadow(color: markerColor.opacity(0.4), radius: 4, y: 2)
            
            // Small capacity label
            Text("\(shelter.availableSpace)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(markerColor.opacity(0.9))
                .cornerRadius(8)
        }
    }
    
    private var markerColor: Color {
        if isSelected { return SafePathColors.accentBlue }
        switch shelter.status {
        case .available:  return SafePathColors.safeGreen
        case .almostFull: return SafePathColors.warningOrange
        case .full, .closed, .unsafe: return SafePathColors.dangerRed
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ShelterMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            ShelterMarkerView(shelter: .preview, isSelected: false)
            ShelterMarkerView(shelter: .previewAlmostFull, isSelected: false)
            ShelterMarkerView(shelter: .preview, isSelected: true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
