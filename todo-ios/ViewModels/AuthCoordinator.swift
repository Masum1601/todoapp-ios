import Foundation
import Combine

// MARK: - Auth Coordinator ViewModel
@MainActor
final class AuthCoordinator: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var loggedInEmail: String = ""

    // Form fields
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    @Published var confirmPasswordText: String = ""
    @Published var isRegisterMode: Bool = false

    // Status state
    @Published var isSubmitting: Bool = false
    @Published var errorNotice: String?
    @Published var hasError: Bool = false

    private let authenticator = FirebaseAuthenticator.shared

    init() {
        verifySession()
    }

    func verifySession() {
        if authenticator.hasActiveSession, let email = authenticator.activeEmail {
            self.isSignedIn = true
            self.loggedInEmail = email
        } else {
            self.isSignedIn = false
            self.loggedInEmail = ""
        }
    }

    func submitForm() async {
        guard validateInputs() else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedEmail = emailText.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if isRegisterMode {
                _ = try await authenticator.signUpWithEmail(email: trimmedEmail, password: passwordText)
            } else {
                _ = try await authenticator.signInWithEmail(email: trimmedEmail, password: passwordText)
            }

            self.loggedInEmail = authenticator.activeEmail ?? trimmedEmail
            self.isSignedIn = true
            resetForm()
        } catch {
            showError(error.localizedDescription)
        }
    }

    func logOut() {
        do {
            try authenticator.signOutCurrentUser()
            self.isSignedIn = false
            self.loggedInEmail = ""
            resetForm()
        } catch {
            showError(error.localizedDescription)
        }
    }

    private func validateInputs() -> Bool {
        let cleanEmail = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanEmail.isEmpty || !cleanEmail.contains("@") {
            showError("Please enter a valid email address.")
            return false
        }
        if passwordText.count < 6 {
            showError("Password must be at least 6 characters.")
            return false
        }
        if isRegisterMode && passwordText != confirmPasswordText {
            showError("Passwords do not match.")
            return false
        }
        return true
    }

    private func showError(_ message: String) {
        self.errorNotice = message
        self.hasError = true
    }

    func resetForm() {
        emailText = ""
        passwordText = ""
        confirmPasswordText = ""
        errorNotice = nil
    }
}
