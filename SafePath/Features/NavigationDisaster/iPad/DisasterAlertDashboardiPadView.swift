import SwiftUI
import MapKit

// Note: Assuming DisasterAlert and related models exist in the project.
// If needed, replace with actual types.
// This view expects DisasterAlertViewModel to be passed or initialized.

struct DisasterAlertDashboardiPadView: View {
    // TODO: Inject or initialize your existing DisasterAlertViewModel here
    // @StateObject private var viewModel = DisasterAlertViewModel()
    
    // Placeholder state for demonstration
    @State private var selectedAlertID: String? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Alert List
            VStack {
                Text("Active Alerts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                List(selection: $selectedAlertID) {
                    // Replace with ForEach(viewModel.alerts)
                    ForEach(1...5, id: \.self) { index in
                        AlertListRowPlaceholder(index: index)
                            .tag(String(index))
                    }
                }
                .listStyle(.plain)
            }
            .frame(width: 320)
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            // Center Panel: Alert Detail
            VStack {
                if let alertID = selectedAlertID {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Alert Details: \(alertID)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("High Severity")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            
                            Text("A severe earthquake has been detected in your area. Please take cover immediately and follow evacuation protocols if instructed. Stay tuned for further updates.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Divider()
                            
                            Text("Instructions")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InstructionRow(number: "1", text: "Drop, Cover, and Hold On.")
                                InstructionRow(number: "2", text: "Stay away from windows and exterior walls.")
                                InstructionRow(number: "3", text: "If outside, move to an open area away from buildings.")
                            }
                            
                            Spacer()
                        }
                        .padding(24)
                    }
                } else {
                    VStack {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Select an alert to view details")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Right Panel: Map Preview
            VStack {
                if selectedAlertID != nil {
                    // Replace with actual map focusing on the alert location
                    Map()
                        .edgesIgnoringSafeArea(.all)
                        .overlay(alignment: .top) {
                            Text("Affected Area")
                                .font(.headline)
                                .padding(12)
                                .background(.thickMaterial)
                                .cornerRadius(8)
                                .padding(.top)
                        }
                } else {
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Map Preview")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.tertiarySystemBackground))
                }
            }
            .frame(width: 350)
        }
        .navigationTitle("Disaster Alerts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper Views
struct AlertListRowPlaceholder: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                Text("Earthquake Warning")
                    .font(.headline)
            }
            Text("Downtown area, magnitude 6.5")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            Text("10 mins ago")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .padding(.top, 4)
        }
    }
}

#Preview {
    DisasterAlertDashboardiPadView()
}
