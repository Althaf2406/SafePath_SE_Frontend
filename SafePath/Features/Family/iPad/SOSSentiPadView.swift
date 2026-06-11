import SwiftUI

struct SOSSentiPadView: View {
    @EnvironmentObject var userVM: UserManagementViewModel
    @EnvironmentObject var emergencyVM: EmergencyStatusViewModel
    @StateObject private var familyVM = FamilySafetyViewModel()
    @State private var isNotified = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Pulse Animation & Main Status
            VStack(spacing: 40) {
                // Back Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(SafePathColors.primaryBlue)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isNotified ? SafePathColors.safeGreen : Color.red, lineWidth: 4)
                        .scaleEffect(isNotified ? 1 : 1.4)
                        .opacity(isNotified ? 0 : 0.5)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isNotified)

                    Image(systemName: isNotified ? "checkmark.circle.fill" : "antenna.radiowaves.left.and.right")
                        .font(.system(size: 100))
                        .foregroundColor(isNotified ? SafePathColors.safeGreen : .red)
                }
                .frame(width: 200, height: 200)

                VStack(spacing: 16) {
                    Text(isNotified ? "Status Updated" : "SOS Sent Successfully")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text(isNotified
                         ? "Your family has been notified of your emergency."
                         : "Help is being notified. Your location is being shared in real-time.")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text(isNotified ? "Back to Family" : "Call Emergency Contact")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(isNotified ? SafePathColors.primaryBlue : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            
            Divider()
            
            // Right Panel: Notified Members / Success Details
            VStack(alignment: .leading, spacing: 24) {
                Text(isNotified ? "Success Details" : "Family Being Notified")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.top, 40)
                    .padding(.horizontal, 40)

                ScrollView {
                    VStack(spacing: 16) {
                        if isNotified {
                            // Table-like Success View
                            VStack(spacing: 2) {
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
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                            .padding(.horizontal, 40)
                        } else {
                            // Notifying List
                            if familyVM.members.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView("Finding members...")
                                        .font(.system(size: 18))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                            } else {
                                ForEach(familyVM.members.filter { $0.id != userVM.currentUser?.id }) { member in
                                    notifyingRow(name: member.name)
                                        .padding(.horizontal, 40)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 450)
            .background(SafePathColors.backgroundLight)
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                if let groupID = userVM.currentUser?.familyGroupIDs.first {
                    await familyVM.fetchGroup(groupID: groupID)
                }
                let lat = userVM.currentUser?.lastLatitude
                let lon = userVM.currentUser?.lastLongitude
                await emergencyVM.triggerSOS(latitude: lat, longitude: lon)

                try? await Task.sleep(nanoseconds: 2_000_000_000)
                withAnimation(.spring()) {
                    isNotified = true
                }
            }
        }
    }

    func notifyingRow(name: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text(name)
                .font(.system(size: 20, weight: .semibold))
            Spacer()
            HStack(spacing: 8) {
                ProgressView().scaleEffect(0.9)
                Text("notifying...")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }

    func successRow(label: String, value: String, isBadge: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            Spacer()
            if isBadge {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(SafePathColors.dangerRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
            }
        }
        .padding(20)
    }
}
