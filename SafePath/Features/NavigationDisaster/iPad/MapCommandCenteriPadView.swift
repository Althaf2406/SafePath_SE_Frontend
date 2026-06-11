import SwiftUI
import MapKit

struct MapCommandCenteriPadView: View {
    // You would inject your ViewModels here to fetch data for the overlays
    // @StateObject private var disasterViewModel = DisasterAlertViewModel()
    // @StateObject private var shelterViewModel = ShelterViewModel()
    
    var body: some View {
        ZStack {
            // Full Screen Map Placeholder
            Map()
                .edgesIgnoringSafeArea(.all)
            
            // Overlays
            VStack {
                HStack(alignment: .top) {
                    // Top Left: Active Disaster Alerts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Active Alerts")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Earthquake Warning (2km)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Severe Flood Risk (Zone B)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                    
                    Spacer()
                    
                    // Top Right: Nearby Shelters
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.green)
                            Text("Nearby Shelters")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("City Hall")
                                    .font(.subheadline)
                                Spacer()
                                Text("1.2km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Text("High School Gym")
                                    .font(.subheadline)
                                Spacer()
                                Text("3.0km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 180)
                    }
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                }
                
                Spacer()
                
                HStack(alignment: .bottom) {
                    // Bottom Left: Current Location
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("My Location")
                                .font(.headline)
                        }
                        Text("Downtown District")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Lat: 37.7749, Lon: -122.4194")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                    
                    Spacer()
                    
                    // Bottom Right: Route Information
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "figure.run")
                                .foregroundColor(.purple)
                            Text("Active Route")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("ETA")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("15 min")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("2.5 km")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                }
            }
        }
        .navigationTitle("Command Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MapCommandCenteriPadView()
}
