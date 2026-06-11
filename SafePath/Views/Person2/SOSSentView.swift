import SwiftUI

struct SOSSentView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @EnvironmentObject var emergencyVM: EmergencyStatusViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    @State private var isNotified = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Minimal Back Bar (no duplicate with AppRouter global bar)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)

            // MARK: - Content
            ScrollView {
                VStack(spacing: 25) {
                    // Pulse Animation Icon
                    ZStack {
                        Circle()
                            .stroke(isNotified ? SafePathColors.safeGreen : Color.red, lineWidth: 2)
                            .scaleEffect(isNotified ? 1 : 1.2)
                            .opacity(isNotified ? 0 : 0.5)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isNotified)

                        Image(systemName: isNotified ? "checkmark.circle.fill" : "antenna.radiowaves.left.and.right")
                            .font(.system(size: 60))
                            .foregroundColor(isNotified ? SafePathColors.safeGreen : .red)
                    }
                    .frame(width: 120, height: 120)
                    .padding(.top, 40)

                    VStack(spacing: 8) {
                        Text(isNotified ? "Status Updated" : "SOS Sent Successfully")
                            .font(.title.bold())
                        Text(isNotified
                             ? "Your family has been notified of your emergency."
                             : "Help is being notified. Your location is being shared in real-time.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Member List
                    VStack(alignment: .leading, spacing: 15) {
                        Text(isNotified ? "Success Details" : "Family Being Notified")
                            .font(.headline)

                        if isNotified {
                            // Table-like Success View
                            VStack(spacing: 1) {
                                successRow(label: "Status", value: "Need Help", isBadge: true)
                                let locationStr: String = {
                                    if let lat = userVM.currentUser?.lastLatitude,
                                       let lon = userVM.currentUser?.lastLongitude {
                                        return String(format: "%.4f, %.4f", lat, lon)
                                    }
                                    return "Location unavailable"
                                }()
                                successRow(label: "Location", value: locationStr)
                                successRow(label: "Time", value: "Just now")
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        } else {
                            // Notifying List
                            VStack(spacing: 12) {
                                if familyVM.members.isEmpty {
                                    HStack {
                                        Spacer()
                                        ProgressView("Finding members...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding()
                                } else {
                                    ForEach(familyVM.members.filter { $0.id != userVM.currentUser?.id }) { member in
                                        notifyingRow(name: member.name)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Final Action Button
                    Button(action: { dismiss() }) {
                        Text(isNotified ? "Back to Family" : "Call Emergency Contact")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isNotified ? SafePathColors.primaryBlue : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                // Fetch family members untuk tampilkan notifying list
                if let groupID = userVM.currentUser?.familyGroupIDs.first {
                    await familyVM.fetchGroup(groupID: groupID)
                }
                // Call real backend API
                let lat = userVM.currentUser?.lastLatitude
                let lon = userVM.currentUser?.lastLongitude
                await emergencyVM.triggerSOS(latitude: lat, longitude: lon)

                // Simulate delay for the UI notification effect
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                withAnimation(.spring()) {
                    isNotified = true
                }
            }
        }
    }

    func notifyingRow(name: String) -> some View {
        HStack {
            Image(systemName: "person.circle.fill").foregroundColor(.secondary)
            Text(name)
            Spacer()
            HStack(spacing: 4) {
                ProgressView().scaleEffect(0.7)
                Text("notifying...")
            }
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    func successRow(label: String, value: String, isBadge: Bool = false) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            if isBadge {
                Text(value).bold()
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(SafePathColors.dangerRed).foregroundColor(.white).cornerRadius(8)
            } else {
                Text(value).bold()
            }
        }
        .padding()
    }
}

#Preview {
    SOSSentView()
        .environmentObject(UserManagementViewModel())
        .environmentObject(EmergencyStatusViewModel())
}


