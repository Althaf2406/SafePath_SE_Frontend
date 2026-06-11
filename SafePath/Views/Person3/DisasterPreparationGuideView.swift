import SwiftUI

struct DisasterPreparationGuideView: View {
    @StateObject private var viewModel = DisasterPreparationViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Using NotificationViewModel just to simulate the alert
    @StateObject private var notificationViewModel = NotificationViewModel()
    @State private var showingAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Disaster Prep Guides")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("Learn how to prepare and respond to various disasters.")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Simulate Alert Button
                Button(action: {
                    notificationViewModel.simulatePrepGuideNotification(for: "Flood")
                    showingAlert = true
                }) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                        Text("Simulate Disaster Alert Notification")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Notification Sent"), message: Text("A simulated notification for Flood has been sent to the Notification Center."), dismissButton: .default(Text("OK")))
                }
                
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.guides) { guide in
                        NavigationLink(destination: DisasterPreparationDetailView(guide: guide)) {
                            HStack {
                                Image(systemName: guide.iconName)
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(guide.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(guide.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}
