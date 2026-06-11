import SwiftUI
import Combine

/// Displays a list of active disaster alerts.
struct DisasterAlertView: View {
    @StateObject private var viewModel = DisasterAlertViewModel()
    @EnvironmentObject var locationService: LocationService
    
    @State private var showNearbyOnly = true
    
    private var displayedAlerts: [DisasterAlert] {
        if showNearbyOnly && locationService.currentLocation != nil {
            return viewModel.nearbyAlerts
        } else {
            return viewModel.allAlerts
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SafePathColors.backgroundLight.ignoresSafeArea()
                
                switch viewModel.state {
                case .idle, .loading:
                    loadingView
                case .loaded:
                    alertListContent(displayedAlerts)
                case .empty:
                    emptyStateView
                case .error(let message):
                    errorStateView(message)
                }
            }
            .navigationTitle("Disaster Alerts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchAllAlerts()
                            if let loc = locationService.currentLocation {
                                await viewModel.fetchNearbyAlerts(location: loc)
                            }
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                viewModel.requestNotificationPermission()
                await viewModel.fetchAllAlerts()
                if let loc = locationService.currentLocation {
                    await viewModel.fetchNearbyAlerts(location: loc)
                }
            }
        }
    }
    
    // MARK: - Alert List
    
    private func alertListContent(_ alerts: [DisasterAlert]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Segmented picker to toggle nearby vs all
                Picker("Filter", selection: $showNearbyOnly) {
                    Text("Nearby").tag(true)
                    Text("All Regions").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 6)
                
                // Attribution
                bmkgAttributionBanner
                
                // Nearby high-severity banner
                let activeHighSeverity = alerts.filter { $0.severity == .critical || $0.severity == .high }
                if !activeHighSeverity.isEmpty {
                    nearbySeverityBanner(count: activeHighSeverity.count)
                }
                
                if alerts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 48))
                            .foregroundColor(SafePathColors.safeGreen)
                            .padding(.top, 40)
                        Text("No Active Alerts Nearby")
                            .font(SafePathFonts.headline)
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Toggle \"All Regions\" to view alerts in other areas.")
                            .font(SafePathFonts.caption)
                            .foregroundColor(SafePathColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.02), radius: 4)
                } else {
                    ForEach(alerts) { alert in
                        NavigationLink(destination: DisasterAlertDetailView(alert: alert, viewModel: viewModel)) {
                            AlertCard(alert: alert)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Components
    
    private var bmkgAttributionBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundColor(SafePathColors.accentBlue)
            Text("Sumber data: BMKG")
                .font(SafePathFonts.caption)
                .foregroundColor(SafePathColors.textSecondary)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(SafePathColors.accentBlue.opacity(0.08))
        .cornerRadius(10)
    }
    
    private func nearbySeverityBanner(count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Active Emergency Alert")
                    .font(SafePathFonts.headline)
                    .foregroundColor(.white)
                Text("\(count) high-severity alerts detected")
                    .font(SafePathFonts.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding(14)
        .background(SafePathColors.dangerRed)
        .cornerRadius(14)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading disaster alerts...")
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 56))
                .foregroundColor(SafePathColors.safeGreen)
            Text("No Active Alerts")
                .font(SafePathFonts.title)
                .foregroundColor(SafePathColors.textPrimary)
            Text("Your area is currently safe.\nStay prepared.")
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func errorStateView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(SafePathColors.warningOrange)
            Text("Unable to Load Alerts")
                .font(SafePathFonts.title)
                .foregroundColor(SafePathColors.textPrimary)
            Text(message)
                .font(SafePathFonts.body)
                .foregroundColor(SafePathColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await viewModel.fetchAllAlerts() }
            }
            .font(SafePathFonts.buttonLabel)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(SafePathColors.accentBlue)
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Alert Card

struct AlertCard: View {
    let alert: DisasterAlert
    
    var body: some View {
        HStack(spacing: 14) {
            // Severity indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(severityColor)
                .frame(width: 5)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    SeverityBadge(severity: alert.severity)
                    Spacer()
                    Text(alert.parsedDate.relativeDisplay)
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.textSecondary)
                }
                
                Text(alert.typeDisplayName)
                    .font(SafePathFonts.headline)
                    .foregroundColor(SafePathColors.textPrimary)
                
                HStack(spacing: 12) {
                    Label("M \(String(format: "%.1f", alert.magnitude))", systemImage: "waveform.path.ecg")
                        .font(SafePathFonts.caption)
                    
                    Label(alert.locationName, systemImage: "mappin.and.ellipse")
                        .font(SafePathFonts.caption)
                        .lineLimit(1)
                }
                .foregroundColor(SafePathColors.textSecondary)
                
                if let dist = alert.distanceKm {
                    Label("\(dist.distanceDisplay) away", systemImage: "location.fill")
                        .font(SafePathFonts.caption)
                        .foregroundColor(SafePathColors.accentBlue)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(SafePathColors.textSecondary)
        }
        .padding(14)
        .safePathCard()
    }
    
    private var severityColor: Color {
        switch alert.severity {
        case .critical: return SafePathColors.dangerRed
        case .high:     return SafePathColors.warningOrange
        case .medium:   return SafePathColors.warningOrange.opacity(0.7)
        case .low:      return SafePathColors.safeGreen
        }
    }
}

// MARK: - Severity Badge

struct SeverityBadge: View {
    let severity: AlertSeverity
    
    var body: some View {
        Text(severity.displayName.uppercased())
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor)
            .cornerRadius(8)
    }
    
    private var badgeColor: Color {
        switch severity {
        case .critical: return SafePathColors.dangerRed
        case .high:     return SafePathColors.warningOrange
        case .medium:   return Color.orange.opacity(0.8)
        case .low:      return SafePathColors.safeGreen
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DisasterAlertView_Previews: PreviewProvider {
    static var previews: some View {
        DisasterAlertView()
            .environmentObject(LocationService())
    }
}
#endif
