import SwiftUI
import MapKit

// Note: This view expects EvacuationRouteViewModel to be passed or initialized.

struct EvacuationDashboardiPadView: View {
    // TODO: Inject or initialize your existing EvacuationRouteViewModel here
    // @StateObject private var viewModel = EvacuationRouteViewModel()
    
    // Placeholder states
    @State private var isRoutingActive = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Route Summary
            VStack(alignment: .leading, spacing: 20) {
                Text("Evacuation Route")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    RouteStepView(
                        icon: "location.fill",
                        title: "Current Location",
                        subtitle: "Downtown District",
                        color: .blue,
                        isLast: false
                    )
                    
                    RouteStepView(
                        icon: "arrow.turn.up.right",
                        title: "Turn right onto Main St.",
                        subtitle: "In 500m",
                        color: .gray,
                        isLast: false
                    )
                    
                    RouteStepView(
                        icon: "arrow.up",
                        title: "Continue straight",
                        subtitle: "For 2km",
                        color: .gray,
                        isLast: false
                    )
                    
                    RouteStepView(
                        icon: "house.fill",
                        title: "City Hall Relief Center",
                        subtitle: "Destination",
                        color: .green,
                        isLast: true
                    )
                }
                
                Spacer()
                
                if isRoutingActive {
                    Button(action: {
                        isRoutingActive = false
                        // viewModel.cancelRoute()
                    }) {
                        Text("Cancel Route")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .frame(width: 320)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Main Area: Large Map & Bottom Panel
            ZStack(alignment: .bottom) {
                // Large Map Placeholder
                Map()
                    .edgesIgnoringSafeArea(.all)
                
                // Bottom Panel: ETA, Distance, Status
                if isRoutingActive {
                    HStack(spacing: 40) {
                        VStack(alignment: .leading) {
                            Text("15 min")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.green)
                            Text("Estimated Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider().frame(height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("2.5 km")
                                .font(.system(size: 36, weight: .bold))
                            Text("Distance Remaining")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider().frame(height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("City Hall Relief Center")
                                .font(.headline)
                            Text("Safe Route Active")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // viewModel.recalculateRoute()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                    }
                    .padding(24)
                    .background(.thickMaterial)
                    .cornerRadius(16)
                    .padding(24)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Evacuation Status")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RouteStepView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .padding(.vertical, 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    EvacuationDashboardiPadView()
}
