import SwiftUI

// Note: Assuming Shelter and related models exist in the project.
// This view expects ShelterViewModel to be passed or initialized.

struct ShelterDirectoryiPadView: View {
    // TODO: Inject or initialize your existing ShelterViewModel here
    // @StateObject private var viewModel = ShelterViewModel()
    
    @State private var selectedShelterID: String? = nil
    
    // Filter states
    @State private var selectedDisasterType: String = "All"
    @State private var selectedFacilityType: String = "All"
    @State private var showOpenOnly: Bool = false
    
    let disasterTypes = ["All", "Earthquake", "Flood", "Fire", "Tsunami"]
    let facilityTypes = ["All", "School", "Community Center", "Stadium", "Hospital"]
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar: Filters
            VStack(alignment: .leading, spacing: 24) {
                Text("Filters")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Disaster Type")
                        .font(.headline)
                    Picker("Disaster Type", selection: $selectedDisasterType) {
                        ForEach(disasterTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 8)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Facility Type")
                        .font(.headline)
                    Picker("Facility Type", selection: $selectedFacilityType) {
                        ForEach(facilityTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 8)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                Toggle("Open Shelters Only", isOn: $showOpenOnly)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Reset filters action
                    selectedDisasterType = "All"
                    selectedFacilityType = "All"
                    showOpenOnly = false
                }) {
                    Text("Reset Filters")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(width: 250)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Content: Shelter List
            VStack {
                Text("Available Shelters")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                List(selection: $selectedShelterID) {
                    // Replace with ForEach(viewModel.shelters)
                    ForEach(1...10, id: \.self) { index in
                        ShelterListRowPlaceholder(index: index)
                            .tag(String(index))
                    }
                }
                .listStyle(.plain)
            }
            .frame(width: 350)
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            // Detail: Selected Shelter
            VStack {
                if let shelterID = selectedShelterID {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header image placeholder
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                )
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("City Hall Relief Center \(shelterID)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.red)
                                    Text("123 Main St, Downtown District")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            HStack(spacing: 20) {
                                DetailBadge(icon: "person.3.fill", title: "Capacity", value: "450 / 500", color: .green)
                                DetailBadge(icon: "building.2.fill", title: "Type", value: "Community Center", color: .blue)
                                DetailBadge(icon: "arrow.up.to.line.alt", title: "Level", value: "Ground Floor", color: .orange)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Supported Disaster Types")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    DisasterTypeTag(name: "Earthquake")
                                    DisasterTypeTag(name: "Flood")
                                    DisasterTypeTag(name: "Fire")
                                }
                            }
                            
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Open Area Available")
                                    .font(.headline)
                            }
                            .padding(.vertical, 8)
                            
                            Spacer(minLength: 40)
                            
                            Button(action: {
                                // Action to start evacuation route
                                // e.g., viewModel.startEvacuation(to: shelter)
                            }) {
                                HStack {
                                    Image(systemName: "figure.run")
                                    Text("Start Evacuation Route")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.bottom)
                        }
                        .padding(24)
                    }
                } else {
                    VStack {
                        Image(systemName: "house")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Select a shelter to view details")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.tertiarySystemBackground))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Shelter Directory")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper Views
struct ShelterListRowPlaceholder: View {
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Relief Center \(index)")
                .font(.headline)
            Text("123 Main St.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("80% Full", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                Spacer()
                Text("2.5 km")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct DetailBadge: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct DisasterTypeTag: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
    }
}

#Preview {
    ShelterDirectoryiPadView()
}
