import SwiftUI

struct DisasterPreparationDetailView: View {
    let guide: DisasterPreparationGuide
    @StateObject private var viewModel = DisasterPreparationViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    Image(systemName: guide.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 80, height: 80)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(guide.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(guide.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Handling Procedures
                VStack(alignment: .leading, spacing: 16) {
                    Text("Handling Procedures")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(guide.handlingProcedures.enumerated()), id: \.offset) { index, procedure in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Text(procedure)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Required Kits Checklist
                VStack(alignment: .leading, spacing: 16) {
                    Text("Required Emergency Kits")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if viewModel.checklistItems.isEmpty {
                        Text("No specific kits required for this disaster.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.checklistItems) { item in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 8))
                                        .padding(.trailing, 8)
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
//                                        Text("Qty: \(item.quantity ?? 1) • \(item.priority.rawValue)")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                
                                if item.id != viewModel.checklistItems.last?.id {
                                    Divider()
                                        .padding(.leading, 32)
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadChecklist(for: guide.disasterType)
        }
    }
}
