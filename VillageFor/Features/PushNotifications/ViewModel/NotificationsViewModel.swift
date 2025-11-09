//
//  NotificationsViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/29/25.
//

import Foundation
import FirebaseAuth
import SwiftUI // Import SwiftUI for @Binding
import UserNotifications // For UNUserNotificationCenter in UserNotificationsService

@MainActor
class NotificationsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var allowMoodCheckins = false
    @Published var allowEpdsAssessments = false
    @Published var allowDailyAffirmations = false

    // MARK: - Services

    private let notificationsService: UserNotificationsService
    private let firestoreService: FirestoreServiceProtocol // Assuming you have this protocol

    @Binding var hasCompletedOnboarding: Bool

    // MARK: - Initializer

    init(notificationsService: UserNotificationsService = UserNotificationsService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService(), // Pass concrete type or mock
         hasCompletedOnboarding: Binding<Bool>) { // Add binding to init
        self.notificationsService = notificationsService
        self.firestoreService = firestoreService
        self._hasCompletedOnboarding = hasCompletedOnboarding // Initialize the binding
    }

    // MARK: - Functions

    /// This function is called whenever a toggle is turned on.
    /// It requests system-level permission from the user to send notifications.
    func requestNotificationsPermission() {
        // We run this in a Task because the permission request is asynchronous.
        Task {
            do {
                try await notificationsService.requestAuthorization()
                print("Notification permission requested.")
            } catch {
                print("Error requesting notification permission: \(error.localizedDescription)")
                // Optionally, show an alert to the user if permission fails.
            }
        }
    }

    /// This function is called by the "Enable all" button.
    func enableAll() {
        allowMoodCheckins = true
        allowEpdsAssessments = true
        allowDailyAffirmations = true
        // After turning on all toggles, request permission if we haven't already.
        requestNotificationsPermission()
    }

    /// This is the final step of the onboarding flow.
    func finishOnboarding(sessionManager: SessionManager, hasCompletedOnboarding: Binding<Bool>) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in when trying to finish onboarding.")
            return
        }

        let preferences = NotificationPreferences(
            moodCheckins: allowMoodCheckins,
            epdsAssessments: allowEpdsAssessments,
            dailyAffirmations: allowDailyAffirmations
        )

        do {
            // Save the preferences to the user's profile in Firestore.
            // Assuming firestoreService.updateUserPreferences can handle NotificationPreferences struct directly
            // or converts it to a dictionary internally if needed by Firestore.
            try await firestoreService.updateUserPreferences(uid: uid, preferences: preferences)
            print("Successfully saved notification preferences to Firestore.")

            if var currentUser = sessionManager.currentUser {
                currentUser.notificationPreferences = preferences // Direct assignment of the struct
                sessionManager.currentUser = currentUser
                print("SessionManager currentUser notification preferences updated locally.")
            } else {
                print("⚠️ Warning: SessionManager.currentUser is nil. Cannot update notification preferences locally.")
            }

            // Set hasCompletedOnboarding to true - This is the trigger for the main app UI.
//            hasCompletedOnboarding.wrappedValue = true
            print("🎉 Onboarding complete! moving to tranition views.")

        } catch {
            print("❌ Error saving notification preferences: \(error.localizedDescription)")
        }
    }
}

