import SwiftUI

// MARK: - Root Content Coordinator
struct ContentView: View {
    @StateObject private var authCoordinator = AuthCoordinator()
    @StateObject private var dashboardVM = TodoDashboardViewModel()

    var body: some View {
        Group {
            if authCoordinator.isSignedIn {
                TodoOverviewView(dashboardVM: dashboardVM, authCoordinator: authCoordinator)
                    .onAppear {
                        dashboardVM.bindRealtimeListener()
                    }
            } else {
                AuthView(authCoordinator: authCoordinator)
            }
        }
    }
}
