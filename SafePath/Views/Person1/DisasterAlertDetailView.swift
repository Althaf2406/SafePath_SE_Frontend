import SwiftUI
import Combine
import MapKit

/// Detail screen for a single disaster alert matching the visual style in Screenshot 5.
struct DisasterAlertDetailView: View {
    let alert: DisasterAlert
    @ObservedObject var viewModel: DisasterAlertViewModel
    
    @EnvironmentObject var locationService: LocationService
    
    @State private var mapPosition: MapCameraPosition
    @State private var showShareSheet = false
    
    init(alert: DisasterAlert, viewModel: DisasterAlertViewModel) {
        self.alert = alert
        self.viewModel = viewModel
        let region = MKCoordinateRegion(
            center: alert.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        _mapPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 1. Alert Header Card matching Screenshot 5
                alertHeaderCard
                
                // 2. Map Preview matching Screenshot 5
                mapPreview
                
                // 3. Safety Instructions matching Screenshot 5
                safetyInstructionsSection
                
                // 4. Action Buttons matching Screenshot 5
                actionButtonsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .onAppear {
            mapPosition = .automatic
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
            ToolbarItem(placement: .principal) {
                Text("Disaster Alert")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["SafePath Alert: \(alert.typeDisplayName) at \(alert.locationName). \(alert.instruction)"])
        }
    }
    
    // MARK: - Back Button
    private struct BackButton: View {
        @Environment(\.dismiss) var dismiss
        var body: some View {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(SafePathColors.primaryBlue)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
    
    // MARK: - Alert Header Card
    private var alertHeaderCard: some View {
        HStack(spacing: 0) {
            // Left vertical red strip
            Rectangle()
                .fill(SafePathColors.dangerRed)
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(SafePathColors.dangerRed)
                            .font(.title2)
                        Text(alert.typeDisplayName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.dangerRed)
                    }
                    
                    Spacer()
                    
                    Text("HIGH SEVERITY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(SafePathColors.dangerRed)
                        .cornerRadius(12)
                }
                
                let timeAgo = alert.parsedDate.timeAgoDisplay()
                let depthString = alert.depth != nil ? " at depth \(alert.depth!)" : ""
                Text("Magnitude \(String(format: "%.1f", alert.magnitude)) detected\(depthString). Epicenter is approximately \(alert.distanceKm != nil ? String(format: "%.1f", alert.distanceKm!) : "4.2") km away near \(alert.locationName). Event recorded \(timeAgo).")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SafePathColors.textPrimary)
                    .lineSpacing(4)
                
                // Recommended Action Red Banner
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Recommended Action: \(alert.instruction.isEmpty ? "Seek open space immediately." : alert.instruction)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SafePathColors.dangerRed)
                .cornerRadius(8)
            }
            .padding(16)
        }
        .background(SafePathColors.lightRedCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Map Preview
    private var disasterRadius: Double {
        alert.severity == .critical ? 50000 : 25000
    }
    
    private var mapPreview: some View {
        ZStack(alignment: .bottomLeading) {
            Map(position: $mapPosition) {
                // 1. Epicenter Annotation
                Annotation("", coordinate: alert.coordinate) {
                    ZStack {
                        Circle()
                            .stroke(SafePathColors.dangerRed, lineWidth: 1.5)
                            .frame(width: 80, height: 80)
                            .scaleEffect(1.2)
                            .opacity(0.3)
                        Circle()
                            .fill(SafePathColors.dangerRed.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Circle()
                            .fill(SafePathColors.dangerRed)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // 2. Disaster Danger Zone (Radius Circle)
                MapCircle(center: alert.coordinate, radius: disasterRadius)
                    .foregroundStyle(SafePathColors.dangerRed.opacity(0.15))
                    .stroke(SafePathColors.dangerRed.opacity(0.5), lineWidth: 2)
                
                // 3. User Location Dot Annotation
                if let userCoord = locationService.currentLocation {
                    Annotation("Your Location", coordinate: userCoord) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 24, height: 24)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .fill(Color.blue)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
            
            // Location Pill Overlay
            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(SafePathColors.dangerRed)
                Text("Epicenter: \(alert.distanceKm != nil ? String(format: "%.1f km SW", alert.distanceKm!) : "4.2 km SW")")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(20)
            .padding(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Safety Instructions
    private var safetyInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Safety Instructions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)
            
            VStack(spacing: 14) {
                instructionRow(icon: "building.2.crop.left.filled.slash", text: "Stay away from buildings and structures.")
                instructionRow(icon: "person.fill.viewfinder", text: "Protect your head and neck.")
                instructionRow(icon: "arrow.up.left.and.arrow.down.right", text: "Move to a clear, open area immediately.")
                instructionRow(icon: "arrow.triangle.turn.up.right.diamond.fill", text: "Follow designated evacuation routes.")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }
    
    private func instructionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(SafePathColors.primaryBlue)
                .frame(width: 32, height: 32)
                .background(SafePathColors.backgroundLight)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SafePathColors.textPrimary)
            Spacer()
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // View Evacuation Route Button
            NavigationLink(destination: Text("Evacuation Map")) { // Person 1 main map/route view
                HStack {
                    Image(systemName: "map.fill")
                    Text("View Evacuation Route")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(12)
            }
            
            // Notify Family Button
            Button(action: { viewModel.onNotifyFamily?(alert) }) {
                HStack {
                    Image(systemName: "megaphone.fill")
                    Text("Notify Family")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SafePathColors.dangerRed)
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                // Mark Safe Button
                Button(action: { viewModel.onMarkSafe?() }) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                        Text("Mark Safe")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.primaryBlue, lineWidth: 1.5)
                    )
                    .cornerRadius(12)
                }
                
                // Save Offline Button
                Button(action: { viewModel.onSaveAlertOffline?(alert) }) {
                    HStack {
                        Image(systemName: "arrow.down.to.line.fill")
                        Text("Save Offline")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(SafePathColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(SafePathColors.backgroundLight)
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Helper ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Extension for parsedDate time ago
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 3600
        
        if secondsAgo < minute {
            return "just now"
        } else if secondsAgo < hour {
            let mins = secondsAgo / minute
            return "\(mins) \(mins == 1 ? "min" : "mins") ago"
        } else {
            let hours = secondsAgo / hour
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DisasterAlertDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DisasterAlertDetailView(
                alert: .preview,
                viewModel: DisasterAlertViewModel()
            )
            .environmentObject(LocationService())
        }
    }
}
#endif
