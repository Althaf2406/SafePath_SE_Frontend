import SwiftUI
import Combine
import PhotosUI

struct EditProfileiPadView: View {
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
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel: Header, Photo & Action
            VStack(spacing: 40) {
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
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Text("Edit Profile")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Keep your emergency information up to date to ensure the fastest response during incidents.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                photoSection
                
                Spacer()
                
                actionSection
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
            .frame(width: 450)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Right Panel: Form Fields
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    basicInfoCard
                    locationInfoCard
                    emergencyContextCard
                }
                .padding(40)
            }
            .frame(maxWidth: .infinity)
            .background(SafePathColors.backgroundLight)
        }
        .onAppear {
            if let user = userVM.currentUser {
                fullName = user.name
                email = user.email
                phone = user.phone ?? ""
                if let lat = user.lastLatitude { latitude = String(lat) }
                if let lon = user.lastLongitude { longitude = String(lon) }
            }
            if let uid = userVM.currentUser?.id {
                profileImageData = UserDefaults.standard.data(forKey: "profile_image_\(uid)")
            }
        }
        .navigationBarHidden(true)
        .overlay(Group { if showSavedToast { toastOverlay } })
    }
    
    private var photoSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                if let data = profileImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 160))
                        .foregroundColor(SafePathColors.textSecondary.opacity(0.3))
                        .frame(width: 160, height: 160)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(SafePathColors.primaryBlue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .offset(x: -10, y: -10)
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
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(SafePathColors.primaryBlue)
            }
        }
    }
    
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("Full Name", text: $fullName)
                    .font(.system(size: 18))
                    .padding(20)
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                TextField("Email Address", text: $email)
                    .font(.system(size: 18))
                    .padding(20)
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Phone Number", text: $phone)
                        .font(.system(size: 18))
                }
                .padding(20)
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            }
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
    
    private var locationInfoCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Latitude")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                HStack(spacing: 12) {
                    Image(systemName: "mappin")
                        .font(.system(size: 20))
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Latitude", text: $latitude)
                        .font(.system(size: 18))
                        .keyboardType(.decimalPad)
                }
                .padding(20)
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Longitude")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SafePathColors.textPrimary)
                HStack(spacing: 12) {
                    Image(systemName: "mappin")
                        .font(.system(size: 20))
                        .foregroundColor(SafePathColors.textSecondary)
                    TextField("Longitude", text: $longitude)
                        .font(.system(size: 18))
                        .keyboardType(.decimalPad)
                }
                .padding(20)
                .background(SafePathColors.backgroundLight.opacity(0.5))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
            }
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
    
    private var emergencyContextCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(SafePathColors.dangerRed)
                .frame(width: 8)
            
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SafePathColors.dangerRed)
                    Text("Emergency Context")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(SafePathColors.dangerRed)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Primary Emergency Contact")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.rectangle.stack.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SafePathColors.textSecondary)
                        TextField("Emergency Contact", text: $emergencyContact)
                            .font(.system(size: 18))
                    }
                    .padding(20)
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Home Address")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(SafePathColors.textPrimary)
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SafePathColors.textSecondary)
                            .padding(.top, 4)
                        TextEditor(text: $homeAddress)
                            .font(.system(size: 18))
                            .frame(height: 100)
                            .background(Color.clear)
                    }
                    .padding(20)
                    .background(SafePathColors.backgroundLight.opacity(0.5))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(SafePathColors.lightBlueCard, lineWidth: 2))
                }
            }
            .padding(32)
        }
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    let lat = Double(latitude) ?? 0.0
                    let lon = Double(longitude) ?? 0.0
                    await userVM.updateProfile(name: fullName, phone: phone, latitude: lat, longitude: lon)
                    withAnimation { showSavedToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation { showSavedToast = false }
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 20))
                    Text("Save Changes")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(SafePathColors.primaryBlue)
                .cornerRadius(16)
            }
            
            Text("Last updated: 2 minutes ago")
                .font(.system(size: 14))
                .foregroundColor(SafePathColors.textSecondary)
        }
    }
    
    private var toastOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(SafePathColors.safeGreen)
                Text("Changes saved successfully")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(Color(red: 0.1, green: 0.15, blue: 0.2))
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
            .padding(.bottom, 60)
        }
    }
}
