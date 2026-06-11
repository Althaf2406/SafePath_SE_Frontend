import SwiftUI

struct EmergencySystemNotification: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background Dimmed
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header Banner
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Earthquake Alert")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red)
                
                VStack(spacing: 15) {
                    HStack(alignment: .top) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Magnitude 6.2 detected 4.2 km away.")
                                .font(.headline)
                            Text("Seek shelter immediately. Follow evacuation routes if instructed.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 10) {
                        Button(action: {}) {
                            Label("View Route", systemImage: "map.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(SafePathColors.primaryBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            Label("I'm Safe", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(SafePathColors.safeGreen.opacity(0.1))
                                .foregroundColor(SafePathColors.safeGreen)
                                .cornerRadius(12)
                        }
                        
                        Button("Dismiss") { dismiss() }
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(30)
            .shadow(radius: 20)
        }
    }
}

#Preview{
    EmergencySystemNotification()
}

//tttes
