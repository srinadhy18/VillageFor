//
//  LoginViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//

import Foundation
import FirebaseAuth // Import FirebaseAuth for authentication operations
import FirebaseFirestore // Import FirebaseFirestore for fetching user profiles

@MainActor // Ensures that all UI updates and published properties are on the main thread
class LoginViewModel: ObservableObject {

    // MARK: - Published Properties for UI Binding

    @Published var email = ""
    @Published var password = ""

    @Published var errorMessage: String? // To display any authentication or profile fetching errors
    @Published var isLoading = false    // To show loading indicators (e.g., on the login button)

    // Properties to control navigation after login
    // This flag is set to true if the user needs to complete (or start) onboarding.
    @Published var navigateToCreateProfile = false

    // MARK: - Services

    // Dependency injection for authentication and Firestore services
    // Allows for easier testing by passing mock services in initializers.
    private let authService: AuthenticationService
    private let firestoreService: FirestoreServiceProtocol // Using the protocol for better abstraction

    // MARK: - Initializer

    // Custom initializer to allow dependency injection
    init(authService: AuthenticationService = AuthenticationService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.authService = authService
        self.firestoreService = firestoreService
    }

    // MARK: - Computed Properties

    // Determines if the login button should be interactable
    var isLoginButtonDisabled: Bool {
        // Button is disabled if email or password fields are empty, or if an operation is already in progress.
        email.isEmpty || password.isEmpty || isLoading
    }

    // MARK: - Core Logic

    /// Handles the user login process.
    /// - Parameter sessionManager: The shared SessionManager instance to update user session state.
    func login(sessionManager: SessionManager) async {
        isLoading = true // Start loading indicator
        errorMessage = nil // Clear any previous error messages

        do {
            // 1. Authenticate user with Firebase Auth
            let firebaseUser = try await authService.signIn(withEmail: email, password: password)
            print("Successfully logged in Firebase user with UID: \(firebaseUser.id)")

            // 2. Fetch the complete user profile from Firestore
            // This profile contains all the custom data (firstName, age, consent, preferences)
            guard let userProfile = try await firestoreService.fetchUserProfile(uid: firebaseUser.id) else {
                // If a Firebase user exists but no corresponding profile in Firestore,
                // it implies a profile needs to be created.
                errorMessage = "User profile not found. Please complete your profile."
                navigateToCreateProfile = true // Direct them to the profile creation screen
                isLoading = false
                return
            }

            // 3. Update the shared SessionManager with the fetched user's complete profile
            sessionManager.currentUser = userProfile
            print("SessionManager.currentUser set after login for user: \(userProfile.email)")

            // 4. Determine if the user has completed all necessary onboarding steps
            // This logic defines what "onboarding complete" means for your app.
            let hasCompletedRequiredProfile = userProfile.firstName != nil && // Assumes firstName is always set first
                                               userProfile.dataConsent != nil &&
                                               userProfile.age != nil &&
                                               userProfile.notificationPreferences != nil

            if hasCompletedRequiredProfile {
                // If all critical fields are present, the user's onboarding is complete.
                // The `VillageForApp`'s `@AppStorage("hasCompletedOnboarding")` property
                // will already be `true` from a previous session, or it was just set `true`
                // in the `NotificationsViewModel` if this was a new completion.
                // This ViewModel *does not* set `hasCompletedOnboarding` directly.
                print(" User profile is complete. The app will transition to the main content.")
                // No need to explicitly set a flag here if `VillageForApp` observes
                // `@AppStorage("hasCompletedOnboarding")` which is set by NotificationsViewModel.
                // If your `SessionManager.isOnboardingComplete` property is also observed by your root view,
                // you would set it here: `sessionManager.isOnboardingComplete = true`
            } else {
                // User logged in, but their profile is incomplete.
                // Trigger navigation to the first onboarding step (CreateProfileView).
                print("⚠️ User profile is incomplete. Navigating to CreateProfileView to finish onboarding.")
                navigateToCreateProfile = true
            }

        } catch {
            // Handle any errors during login or profile fetching
            print("❌ Error during login or fetching user profile: \(error.localizedDescription)")
            errorMessage = error.localizedDescription // Display error to the user
        }

        isLoading = false // Stop loading indicator
    }
}
