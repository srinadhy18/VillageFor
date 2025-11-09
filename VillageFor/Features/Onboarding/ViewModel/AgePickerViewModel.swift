//
//  AgePickerViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AgePickerViewModel: ObservableObject {

    let ageRange = 18...100
    @Published var selectedAge: Int? = 18 // Default to 34 or nil if no default
    let itemHeight: CGFloat = 80
    @Published var navigateToNotificationsScreen = false

   
    @Binding var hasCompletedOnboarding: Bool

  
    init(hasCompletedOnboarding: Binding<Bool>) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
        // You can set a default selectedAge here if desired, e.g., self.selectedAge = 34
    }

    private let firestoreService = FirestoreService()

    func continueTapped(sessionManager: SessionManager) async {
        // Ensure we have a selected age and a logged-in user
        guard let age = selectedAge, let uid = Auth.auth().currentUser?.uid else {
            print("Error: No age selected or user not logged in.")
            // we may need to display an alert to the user here.
            return
        }

        do {
            //update the user's age in the database
            try await firestoreService.updateUserAge(uid: uid, age: age)
            print("User age (\(age)) saved successfully in Firestore.")


            // This ensures our app's local state for the user is up-to-date.
            if var currentUser = sessionManager.currentUser {
                currentUser.age = age
                sessionManager.currentUser = currentUser
                print("SessionManager currentUser age updated to: \(currentUser.age ?? 0)")
            } else {
                print("Warning: SessionManager.currentUser is nil. Cannot update age locally.")
                // This scenario indicates a potential issue upstream; currentUser should ideally exist by now.
            }

            // Signal to AgePickerView to navigate to the Notifications screen
            self.navigateToNotificationsScreen = true
            print("Navigating to Notifications screen.")

            // IMPORTANT: DO NOT set hasCompletedOnboarding = true here.
            // This flag is the very last step, set in NotificationsViewModel.

        } catch {
            print("Error updating user age: \(error.localizedDescription)")
            // Optionally, show an error alert to the user
        }
    }
}
