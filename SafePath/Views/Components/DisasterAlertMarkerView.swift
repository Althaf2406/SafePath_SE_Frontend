import SwiftUI
import Combine

/// Disaster alert marker for SwiftUI context.
struct DisasterAlertMarkerView: View {
    let alert: DisasterAlert
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Pulsing outer ring for critical/high
                if alert.severity == .critical || alert.severity == .high {
                    Circle()
                        .stroke(SafePathColors.dangerRed.opacity(0.3), lineWidth: 2)
                        .frame(width: 48, height: 48)
                }
                
                Circle()
                    .fill(SafePathColors.dangerRed)
                    .frame(width: 36, height: 36)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .shadow(color: SafePathColors.dangerRed.opacity(0.4), radius: 4, y: 2)
            
            // Magnitude label
            Text("M\(String(format: "%.1f", alert.magnitude))")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(SafePathColors.dangerRed.opacity(0.9))
                .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DisasterAlertMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            DisasterAlertMarkerView(alert: .preview)
            DisasterAlertMarkerView(alert: .previewCritical)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
