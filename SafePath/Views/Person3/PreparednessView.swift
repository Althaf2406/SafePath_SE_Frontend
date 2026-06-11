import SwiftUI

struct PreparednessView: View {
    @EnvironmentObject var viewModel: PreparednessViewModel
    @EnvironmentObject var userVM: UserManagementViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Be ready before disaster happens.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, -10)

                    overallReadinessCard
                    localRiskProfileCard
                    emergencyKitCard
                    quickActionsSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Preparedness")
            .task {
                let lat = userVM.currentUser?.lastLatitude ?? -7.2504
                let lng = userVM.currentUser?.lastLongitude ?? 112.7688
                viewModel.loadMandatoryItems(userId: userVM.currentUser?.id)
                await viewModel.load(lat: lat, lng: lng)
            }
        }
    }

    // MARK: - Overall Readiness

    private var overallReadinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("OVERALL READINESS")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline) {
                        Text("\(Int(viewModel.overallReadiness * 100))%")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                Image(systemName: "shield.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            ProgressView(value: viewModel.overallReadiness)
                .tint(.blue)

            Text("\(viewModel.completedItemsCount) of \(viewModel.totalItemsCount) items prepared")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    // MARK: - Local Risk Profile

    private var localRiskProfileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                Text("Local Risk Profile")
                    .font(.headline)
            }
            .foregroundColor(.primary)

            if viewModel.riskProfiles.isEmpty {
                Text("Loading risk profiles...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.riskProfiles) { risk in
                    HStack {
                        Image(systemName: risk.iconName)
                            .foregroundColor(risk.level.color)
                            .frame(width: 30, height: 30)
                            .background(risk.level.color.opacity(0.1))
                            .clipShape(Circle())

                        Text(risk.type)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        RiskBadge(level: risk.level)
                    }
                    .padding()
                    .background(risk.level.color.opacity(0.05))
                    .cornerRadius(12)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Emergency Kit

    private var emergencyKitCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "cross.case")
                Text("Emergency Kit")
                    .font(.headline)
            }

            Text("Essential items for 72-hour survival.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 24) {
                CircularProgressView(
                    progress: viewModel.overallReadiness,
                    text: "\(viewModel.completedItemsCount)/\(viewModel.totalItemsCount)"
                )

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.emergencyKit) { item in
                        HStack {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isChecked ? .green : .secondary)
                            Text(item.name)
                                .foregroundColor(item.isChecked ? .secondary : .primary)
                                .strikethrough(item.isChecked)
                                .multilineTextAlignment(.leading)
                        }
                        .font(.subheadline)
                        .buttonStyle(.plain)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .cardStyle()
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.top, 8)

            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Emergency Checklist",
                    icon: "checklist",
                    backgroundColor: Color.blue.opacity(0.15),
                    foregroundColor: .primary,
                    action: ChecklistView()
                )

                QuickActionButton(
                    title: "First Aid Guide",
                    icon: "bandage",
                    backgroundColor: Color.blue.opacity(0.15),
                    foregroundColor: .primary,
                    action: FirstAidGuideView()
                )
            }

            QuickActionButton(
                title: "Disaster Prep Guide",
                icon: "book.fill",
                backgroundColor: Color.blue.opacity(0.15),
                foregroundColor: .primary,
                action: DisasterPreparationGuideView(),
                isFullWidth: true
            )
        }
    }
}

// MARK: - Risk Badge Component

struct RiskBadge: View {
    let level: RiskLevel

    var body: some View {
        Text(level.rawValue)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(level.color)
            .cornerRadius(8)
    }
}

// MARK: - Quick Action Button Component

struct QuickActionButton<Destination: View>: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: Destination
    var isFullWidth: Bool = false

    var body: some View {
        NavigationLink(destination: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: isFullWidth ? 80 : 100)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

struct PreparednessView_Previews: PreviewProvider {
    static var previews: some View {
        PreparednessView()
            .environmentObject(PreparednessViewModel())
    }
}
