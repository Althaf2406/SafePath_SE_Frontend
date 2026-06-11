import SwiftUI
import Combine

/// Person 2: User registration screen matching the screenshot design.
struct RegisterView: View {
    @Environment(\.dismiss) var dismiss

    @State private var fullName:        String = ""
    @State private var email:           String = ""
    @State private var password:        String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmVisible:  Bool = false

    @EnvironmentObject var userVM: UserManagementViewModel
    @State private var showAlert = false

    // Menggunakan global userVM agar ketika registrasi sukses,
    // RootView otomatis berpindah ke AppRouter.

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create Account")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.textPrimary)
                    Text("Join SafePath and prepare for emergencies.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // MARK: - Input Fields
                VStack(spacing: 14) {
                    inputField(icon: "person",   placeholder: "Full Name",     text: $fullName)
                    inputField(icon: "envelope", placeholder: "Email Address", text: $email, keyboardType: .emailAddress)
                    passwordField(placeholder: "Password",         text: $password,         isVisible: $isPasswordVisible)
                    passwordField(placeholder: "Confirm Password", text: $confirmPassword,  isVisible: $isConfirmVisible)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Register Button
                Button(action: {
                    Task {
                        print("👉 [DEBUG] Tombol Register ditekan!")
                        guard password == confirmPassword else {
                            print("👉 [DEBUG] Gagal: Password tidak sama.")
                            userVM.errorMessage = "Passwords do not match."
                            showAlert = true
                            return
                        }
                        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
                            print("👉 [DEBUG] Gagal: Nama kosong.")
                            userVM.errorMessage = "Please enter your full name."
                            showAlert = true
                            return
                        }
                        print("👉 [DEBUG] Memanggil backend userVM.register...")
                        await userVM.register(name: fullName, email: email, password: password)
                        print("👉 [DEBUG] Selesai memanggil backend. Error: \(String(describing: userVM.errorMessage)), isLoggedIn: \(userVM.isLoggedIn)")
                        
                        if userVM.errorMessage != nil && !userVM.isLoggedIn {
                            print("👉 [DEBUG] Menampilkan alert error!")
                            showAlert = true
                        }
                    }
                }) {
                    HStack {
                        if userVM.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        Text("Register")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(SafePathColors.primaryBlue)
                        .cornerRadius(14)
                        .shadow(color: SafePathColors.primaryBlue.opacity(0.3), radius: 8, y: 4)
                }
                .disabled(userVM.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: - Divider OR
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(SafePathColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                    Text("OR")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SafePathColors.textSecondary)
                    Rectangle()
                        .fill(SafePathColors.textSecondary.opacity(0.2))
                        .frame(height: 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: - Continue with Apple
                Button(action: {
                    // TODO: Person 2 — Apple Sign In
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Continue with Apple")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Color.black)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: - Login Link
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(SafePathColors.textSecondary)
                    Button(action: { dismiss() }) {
                        Text("Login")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }
                }
                .padding(.bottom, 24)

                // MARK: - Privacy Notice
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 14))
                        .foregroundColor(SafePathColors.primaryBlue.opacity(0.7))
                    Text("Your location and emergency data are used only for safety features.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SafePathColors.textSecondary)
                        .lineSpacing(2)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SafePathColors.lightBlueCard.opacity(0.4))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(SafePathColors.lightBlueCard, lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(SafePathColors.backgroundLight.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .alert("Registration Failed", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                userVM.clearError()
            }
        } message: {
            Text(userVM.errorMessage ?? "An unknown error occurred.")
        }
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
        }
    }

    // MARK: - Reusable Input Field

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(SafePathColors.textSecondary)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
        )
    }

    // MARK: - Reusable Password Field

    private func passwordField(
        placeholder: String,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 15))
                .foregroundColor(SafePathColors.textSecondary)
                .frame(width: 20)
            if isVisible.wrappedValue {
                TextField(placeholder, text: text)
                    .font(.system(size: 15))
            } else {
                SecureField(placeholder, text: text)
                    .font(.system(size: 15))
            }
            Button(action: { isVisible.wrappedValue.toggle() }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .font(.system(size: 15))
                    .foregroundColor(SafePathColors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SafePathColors.lightBlueCard, lineWidth: 1.5)
        )
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
