import SwiftUI

// MARK: - Authentication View (Unified Login & Registration)
struct AuthView: View {
    @ObservedObject var authCoordinator: AuthCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Logo & Branding
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.98, green: 0.45, blue: 0.25), Color(red: 0.96, green: 0.32, blue: 0.45)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 76, height: 76)
                                .shadow(color: Color(red: 0.98, green: 0.45, blue: 0.25).opacity(0.35), radius: 10, y: 5)

                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 30)

                        Text("TaskFocus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)

                        Text("Organize with speed and clarity")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    // Mode Toggle: Sign In vs Sign Up
                    Picker("Auth Mode", selection: $authCoordinator.isRegisterMode) {
                        Text("Sign In").tag(false)
                        Text("Create Account").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Form Fields
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            TextField("name@example.com", text: $authCoordinator.emailText)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled(true)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                            SecureField("At least 6 characters", text: $authCoordinator.passwordText)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        if authCoordinator.isRegisterMode {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm Password")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                SecureField("Repeat password", text: $authCoordinator.confirmPasswordText)
                                    .padding(12)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal)

                    // Action Button
                    Button {
                        Task {
                            await authCoordinator.submitForm()
                        }
                    } label: {
                        HStack {
                            if authCoordinator.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(authCoordinator.isRegisterMode ? "Create Account" : "Sign In")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.45, blue: 0.25), Color(red: 0.96, green: 0.32, blue: 0.45)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color(red: 0.98, green: 0.45, blue: 0.25).opacity(0.3), radius: 6, y: 3)
                    }
                    .disabled(authCoordinator.isSubmitting)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .animation(.easeInOut(duration: 0.2), value: authCoordinator.isRegisterMode)
            .alert("Notice", isPresented: $authCoordinator.hasError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authCoordinator.errorNotice ?? "An error occurred.")
            }
        }
    }
}
