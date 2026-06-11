import SwiftUI
import Combine

/// Person 3: Customize Checklist screen — fully offline-capable.
/// Items can be added and toggled even without network connectivity.
/// Changes are queued and auto-synced to the backend when online.
struct CustomizeChecklistView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var preparednessVM: PreparednessViewModel

    @StateObject private var viewModel: CustomizeChecklistViewModel

    init() {
        // Placeholder; real init happens via onAppear because we need the EnvironmentObject.
        // We use a temporary VM that will be replaced once the env object is available.
        // Actual wiring happens in makeViewModel().
        _viewModel = StateObject(wrappedValue: CustomizeChecklistViewModel._placeholder)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                // Offline banner
                if viewModel.isOffline {
                    offlineBanner
                }

                // Pending sync badge
                if viewModel.pendingCount > 0 {
                    pendingBadge
                }

                // Header
                headerView

                // Form Card
                formCard

                // Recently Added Items Section
                recentlyAddedSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
            }
            .background(SafePathColors.backgroundLight.ignoresSafeArea())
            .onAppear {
                viewModel.syncWith(preparednessVM)
            }
            .onChange(of: viewModel.editingItemId) { newValue in
                if newValue != nil {
                    withAnimation {
                        proxy.scrollTo("formTop", anchor: .top)
                    }
                }
            }
        }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 14, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("Mode Offline")
                    .font(.system(size: 14, weight: .bold))
                Text("Perubahan disimpan lokal & dikirim saat online kembali.")
                    .font(.system(size: 12))
                    .opacity(0.85)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .padding(12)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }

    // MARK: - Pending Sync Badge

    private var pendingBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .foregroundColor(SafePathColors.primaryBlue)
            Text("\(viewModel.pendingCount) perubahan menunggu sinkronisasi")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SafePathColors.primaryBlue)
            Spacer()
        }
        .padding(10)
        .background(SafePathColors.primaryBlue.opacity(0.08))
        .cornerRadius(10)
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.editingItemId != nil ? "Edit Checklist Item" : "Customize Checklist")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)

            Text("Update your emergency supplies for specific disaster types.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SafePathColors.textSecondary)
                .lineLimit(2)
        }
    }

    // MARK: - Form Card
    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Anchor for scrolling
            Color.clear.frame(height: 1).id("formTop")

            // Item Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Item Name")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("e.g. Tactical Flashlight", text: $viewModel.itemName)
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                    )
            }

            // Category & Quantity Row
            HStack(spacing: 12) {
                // Category Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)

                    Menu {
                        ForEach(viewModel.categories, id: \.self) { cat in
                            Button(cat.displayName) { viewModel.selectedCategory = cat }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCategory.displayName)
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(SafePathColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                }

                // Quantity Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quantity")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)

                    Menu {
                        ForEach(1...10, id: \.self) { num in
                            Button("\(num)") { viewModel.quantity = num }
                        }
                    } label: {
                        HStack {
                            Text("\(viewModel.quantity)")
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                    .frame(width: 100)
                }
            }

            // Priority & Disaster Type Row
            HStack(spacing: 12) {
                // Priority Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text("Priority")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)

                    HStack(spacing: 0) {
                        Button(action: { viewModel.priority = .high }) {
                            Text("High")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(viewModel.priority == .high ? .white : SafePathColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.priority == .high ? SafePathColors.primaryBlue : SafePathColors.lightBlueCard)
                        }

                        Button(action: { viewModel.priority = .medium }) {
                            Text("Medium")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(viewModel.priority == .medium ? .white : SafePathColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(viewModel.priority == .medium ? SafePathColors.primaryBlue : SafePathColors.lightBlueCard)
                        }
                    }
                    .cornerRadius(10)
                }

                // Disaster Type Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Disaster Type")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)

                    Menu {
                        ForEach(viewModel.disasterTypes, id: \.self) { type in
                            Button(type) { viewModel.disasterType = type }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.disasterType)
                                .foregroundColor(SafePathColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(SafePathColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(SafePathColors.backgroundLight.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
                        )
                    }
                }
            }
            .padding(.bottom, 8)

            // Save / Update Item Button
            Button(action: { viewModel.saveItem() }) {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: viewModel.isOffline ? "arrow.down.to.line.alt" : "square.and.arrow.down.fill")
                    }
                    Text(viewModel.editingItemId != nil 
                         ? (viewModel.isOffline ? "Update Lokal (Offline)" : "Update Item") 
                         : (viewModel.isOffline ? "Simpan Lokal (Offline)" : "Save Item"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isSaving ? SafePathColors.primaryBlue.opacity(0.6) : SafePathColors.primaryBlue)
                .cornerRadius(12)
            }
            .disabled(viewModel.isSaving || viewModel.itemName.isEmpty)

            // Clear / Cancel Form Button
//            Button(action: { viewModel.resetForm() }) {
//                HStack(spacing: 8) {
//                    Image(systemName: viewModel.editingItemId != nil ? "xmark" : "trash.fill")
//                    Text(viewModel.editingItemId != nil ? "Cancel Edit" : "Clear Form")
//                        .font(.system(size: 16, weight: .bold, design: .rounded))
//                }
//                .foregroundColor(SafePathColors.dangerRed)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 14)
//                .background(Color.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(SafePathColors.dangerRed, lineWidth: 1.5)
//                )
//                .cornerRadius(12)
//            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Recently Added Section
    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENTLY ADDED ITEMS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(SafePathColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                if viewModel.customItems.isEmpty {
                    Text("No items added yet.")
                        .font(.system(size: 14))
                        .foregroundColor(SafePathColors.textSecondary)
                        .padding()
                } else {
                    ForEach(viewModel.customItems) { item in
                        HStack(spacing: 12) {
                            // Tappable checkbox — works offline!
                            Button(action: { viewModel.toggleItem(item) }) {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(item.isChecked ? SafePathColors.safeGreen : SafePathColors.textSecondary)
                            }

                            Image(systemName: iconForCategory(item.category))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorForCategory(item.category))
                                .frame(width: 40, height: 40)
                                .background(colorForCategory(item.category).opacity(0.1))
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(item.isChecked ? SafePathColors.textSecondary : SafePathColors.textPrimary)
                                    .strikethrough(item.isChecked, color: SafePathColors.textSecondary)
                                Text("\(item.category.displayName) • Qty: \(item.quantity ?? 1) • \(item.priority.rawValue) Priority")
                                    .font(.system(size: 12))
                                    .foregroundColor(SafePathColors.textSecondary)
                            }

                            Spacer()

                            // Edit Button
                            Button(action: {
                                viewModel.startEditing(item)
                                // Not strictly scrolling to top, but users can see the form
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(SafePathColors.primaryBlue)
                                    .padding(.trailing, 4)
                            }

                            // Delete Button
                            Button(action: { viewModel.deleteItem(id: item.id) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(SafePathColors.dangerRed)
                            }
                        }
                        .padding(12)
                        .background(
                            item.isChecked
                                ? SafePathColors.safeGreen.opacity(0.05)
                                : Color.white
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    item.isChecked ? SafePathColors.safeGreen.opacity(0.3) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: item.isChecked)
                    }
                }
            }
        }
    }

    // MARK: - Category Helpers
    private func iconForCategory(_ category: KitCategory) -> String {
        switch category {
        case .firstAid:      return "cross.case.fill"
        case .lighting:      return "flashlight.on.fill"
        case .water:         return "drop.fill"
        case .food:          return "fork.knife"
        case .communication: return "radio.fill"
        case .navigation:    return "map.fill"
        case .clothing:      return "tshirt.fill"
        case .tools:         return "wrench.and.screwdriver.fill"
        case .hygiene:       return "hands.sparkles.fill"
        case .documents:     return "doc.fill"
        }
    }

    private func colorForCategory(_ category: KitCategory) -> Color {
        switch category {
        case .firstAid:                            return SafePathColors.safeGreen
        case .water, .communication, .navigation:  return SafePathColors.primaryBlue
        case .lighting, .food:                     return SafePathColors.warningOrange
        case .tools:                               return SafePathColors.dangerRed
        default:                                   return SafePathColors.offlineGray
        }
    }
}

// MARK: - Color Hex Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:   Double(r) / 255,
                  green: Double(g) / 255,
                  blue:  Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

#Preview {
    CustomizeChecklistView()
        .environmentObject(PreparednessViewModel())
}
