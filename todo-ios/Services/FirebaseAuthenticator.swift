import Foundation
import FirebaseAuth

// MARK: - Firebase Authentication Handler
final class FirebaseAuthenticator {
    static let shared = FirebaseAuthenticator()
    private let auth = Auth.auth()

    private init() {}

    // Currently logged-in user UID
    var activeUserId: String? {
        auth.currentUser?.uid
    }

    // Currently logged-in user email
    var activeEmail: String? {
        auth.currentUser?.email
    }

    // Session status
    var hasActiveSession: Bool {
        auth.currentUser != nil
    }

    // Create user account
    func signUpWithEmail(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }

    // Authenticate existing account
    func signInWithEmail(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }

    // Invalidate active session
    func signOutCurrentUser() throws {
        try auth.signOut()
    }
}
