import SwiftUI
import Combine

/// Person 2: User login screen matching the screenshot design.
struct LoginView: View {

    @State private var email: String = "admin@gmail.com"
    @State private var password: String = "123456"
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToRegister: Bool = false
    @EnvironmentObject var userVM: UserManagementViewModel
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Header
                    VStack(spacing: 6) {
                        Text("Welcome Back")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(SafePathColors.textPrimary)
                        Text("Sign in to SafePath")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.bottom, 32)

                    // MARK: - Input Fields
                    VStack(spacing: 14) {

                        // Email
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 15))
                                .foregroundColor(SafePathColors.textSecondary)
                                .frame(width: 20)
                            TextField("Email address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
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

                        // Password
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .font(.system(size: 15))
                                .foregroundColor(SafePathColors.textSecondary)
                                .frame(width: 20)
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .font(.system(size: 15))
                            } else {
                                SecureField("Password", text: $password)
                                    .font(.system(size: 15))
                            }
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
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
                    .padding(.horizontal, 24)

                    // MARK: - Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot password?") {}
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(SafePathColors.primaryBlue)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 24)

                    // MARK: - Login Button
                    Button(action: {
                        Task {
                            await userVM.login(email: email, password: password)
                            // RootView automatically switches to AppRouter when isLoggedIn = true
                            if userVM.errorMessage != nil {
                                showAlert = true
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if userVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Login")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
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

                    // MARK: - Divider OR
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(SafePathColors.textSecondary.opacity(0.2))
                            .frame(height: 1)
                        Text("or")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(SafePathColors.textSecondary)
                        Rectangle()
                            .fill(SafePathColors.textSecondary.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)

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
                    .padding(.bottom, 24)

                    // MARK: - Register Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(SafePathColors.textSecondary)
                        Button(action: { navigateToRegister = true }) {
                            Text("Register account")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(SafePathColors.primaryBlue)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(SafePathColors.backgroundLight.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SafePath")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(SafePathColors.primaryBlue)
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
            }
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    userVM.clearError()
                }
            } message: {
                Text(userVM.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

#Preview {
    LoginView()
}
