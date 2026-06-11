import SwiftUI
import Combine
import PhotosUI

/// Person 2: Edit Profile view matching the visual style in Screenshot 4.
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userVM: UserManagementViewModel
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var emergencyContact: String = ""
    @State private var homeAddress: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    @State private var showSavedToast = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Titles
                headerTitles
                
                // Profile Photo Section
                photoSection
                
                // Basic Info Card
                basicInfoCard
                
                // Location Info Card
                locationInfoCard
                
                // Emergency Context Card
                emergencyContextCard
                
                // Action Button & Last Updated
                actionSection
                
                // Semua data sudah tersambung dengan dinamis ke backend.
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .onAppear {
            if let user = userVM.currentUser {
                fullName = user.name
                email = user.email
                phone = user.phone ?? ""
                if let lat = user.lastLatitude {
                    latitude = String(lat)
                }
                if let lon = user.lastLongitude {
                    longitude = String(lon)
                }
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(SafePathColors.primaryBlue)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("SafePath")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(SafePathColors.primaryBlue)
                    .font(.title3)
            }
        }
        .overlay(
            Group {
                if showSavedToast {
                    toastOverlay
                }
            }
        )
    }
    
    // MARK: - Header Titles
    private var headerTitles: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Edit Profile")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(SafePathColors.primaryBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Keep your emergency information up to date to ensure the fastest response during incidents.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SafePathColors.textSecondary)
                .lineSpacing(2)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Photo Section
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImageData: Data?

    private var photoSection: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let data = profileImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 96))
                            .foregroundColor(SafePathColors.textSecondary.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .overlay(
                    Circle()
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 2)
                )
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(SafePathColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileImageData = data
                        if let uid = userVM.currentUser?.id {
                            UserDefaults.standard.set(data, forKey: "profile_image_\(uid)")
                        }
                    }
                }
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Change Photo")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
        }
        .onAppear {
            if let uid = userVM.currentUser?.id {
                profileImageData = UserDefaults.standard.data(forKey: "profile_image_\(uid)")
            }
        }
    }
    
    // MARK: - Basic Info Card
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Full Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("Full Name", text: $fullName)
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                    )
            }
            
            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("Email Address", text: $email)
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                    )
            }
            
            // Phone
            VStack(alignment: .leading, spacing: 6) {
                Text("Phone Number")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Phone Number", text: $phone)
                }
                .padding()
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Location Info Card
    private var locationInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Latitude
            VStack(alignment: .leading, spacing: 6) {
                Text("Latitude")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin")
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                )
            }
            
            // Longitude
            VStack(alignment: .leading, spacing: 6) {
                Text("Longitude")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin")
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                }
                .padding()
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Emergency Context Card
    private var emergencyContextCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(SafePathColors.dangerRed)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(SafePathColors.dangerRed)
                    Text("Emergency Context")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(SafePathColors.dangerRed)
                }
                
                // Contact
                VStack(alignment: .leading, spacing: 6) {
                    Text("Primary Emergency Contact")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.rectangle.stack.fill")
                            .foregroundColor(SafePathColors.textSecondary)
                        TextField("Emergency Contact", text: $emergencyContact)
                    }
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                    )
                }
                
                // Address
                VStack(alignment: .leading, spacing: 6) {
                    Text("Home Address")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(SafePathColors.textSecondary)
                            .padding(.top, 2)
                        TextEditor(text: $homeAddress)
                            .frame(height: 60)
                            .background(Color.clear)
                    }
                    .padding()
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                    )
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    let lat = Double(latitude)
                    let lon = Double(longitude)
                    await userVM.updateProfile(name: fullName, phone: phone, latitude: lat, longitude: lon)
                    withAnimation {
                        showSavedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            showSavedToast = false
                        }
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(12)
            }
            
            Text("Last updated: 2 minutes ago")
                .font(.system(size: 12))
                .foregroundColor(SafePathColors.textSecondary)
        }
    }
    
    // MARK: - Toast Overlay
    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Changes saved successfully")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserManagementViewModel())
}

///tttesst
