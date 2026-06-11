import SwiftUI

/// Person 3: Offline Survival Mode — displays the last-cached Emergency Kit
/// data so users can still access their preparedness information without network.
struct OfflineSurvivalView: View {

    @StateObject private var viewModel = OfflineSurvivalViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Status Header
                statusHeader

                // Readiness Summary
                if !viewModel.cachedEmergencyKit.isEmpty {
                    readinessSummaryCard
                    emergencyKitList
                } else {
                    emptyStateCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Offline Resources")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadCachedData() }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(viewModel.isOfflineMode ? Color.orange.opacity(0.15) : Color.green.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: viewModel.isOfflineMode ? "wifi.slash" : "wifi")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(viewModel.isOfflineMode ? .orange : .green)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isOfflineMode ? "Mode Offline Aktif" : "Sedang Online")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(viewModel.isOfflineMode ? .orange : .green)
                    Text(viewModel.lastSyncedText)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .background(
                viewModel.isOfflineMode
                    ? Color.orange.opacity(0.07)
                    : Color.green.opacity(0.07)
            )
            .cornerRadius(14)

            Text("Data Emergency Kit di bawah ini berasal dari sinkronisasi terakhir saat online.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Readiness Summary Card

    private var readinessSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.blue)
                Text("Kesiapan Darurat")
                    .font(.headline)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(viewModel.readiness * 100))%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
                Text("siap")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: viewModel.readiness)
                .tint(.blue)

            Text("\(viewModel.completedCount) dari \(viewModel.totalCount) item sudah siap")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Emergency Kit List

    private var emergencyKitList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EMERGENCY KIT (CACHE)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(viewModel.cachedEmergencyKit) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(item.isChecked ? .green : .gray)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(item.isChecked ? .secondary : .primary)
                                .strikethrough(item.isChecked, color: .secondary)
                            if let qty = item.quantity {
                                Text("Qty: \(qty) • \(item.category.displayName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Text(item.priority.rawValue)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(priorityColor(item.priority))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(priorityColor(item.priority).opacity(0.1))
                            .cornerRadius(6)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 16)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

            // Read-only notice
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("Halaman ini hanya baca. Centang item di halaman Checklist utama.")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Empty State

    private var emptyStateCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            Text("Belum Ada Data Cache")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Buka halaman Preparedness saat online terlebih dahulu agar data tersimpan untuk akses offline.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Helper

    private func priorityColor(_ priority: ChecklistPriority) -> Color {
        switch priority {
        case .high:   return .red
        case .medium: return .blue
        case .low:    return .green
        }
    }
}

#Preview {
    NavigationStack {
        OfflineSurvivalView()
    }
}
