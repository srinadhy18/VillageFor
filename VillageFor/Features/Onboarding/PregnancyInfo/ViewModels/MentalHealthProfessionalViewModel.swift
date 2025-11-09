//
//  MentalHealthProfessionalViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 8/12/25.
//


import Foundation

@MainActor
class MentalHealthProfessionalViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var navigateToNotifications = false

    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
    }

    /// This is the single function that saves all collected data to Firebase.
    func saveAllOnboardingData(data: OnboardingData, sessionManager: SessionManager) async {
        isLoading = true
        errorMessage = nil

        guard let uid = sessionManager.currentUser?.id else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }

        // --- Final Validation ---
        guard let pregnancyStatus = data.pregnancyStatus,
              let isFirstPregnancy = data.isFirstPregnancy,
              let isPostpartum = data.isPostpartum,
              let workingWithPro = data.workingWithMentalHealthPro else {
            errorMessage = "Please complete all selections to continue."
            isLoading = false
            return
        }

        if isPostpartum == .yes {
            guard data.postpartumWeeks != nil, data.isFirstPostpartumExperience != nil else {
                errorMessage = "Please complete all postpartum details."
                isLoading = false
                return
            }
        }
        
        // --- Firebase Write Operation ---
        do {
            try await firestoreService.updateUserPregnancyPostpartumData(
                uid: uid,
                pregnancyStatus: pregnancyStatus.rawValue,
                isFirstPregnancy: isFirstPregnancy == .yes,
                isPostpartum: isPostpartum == .yes,
                postpartumWeeks: data.postpartumWeeks,
                isFirstPostpartumExperience: data.isFirstPostpartumExperience == .yes,
                mentalHealthProfessionalType: workingWithPro.rawValue
            )
            
            print("Successfully saved all onboarding data to Firestore.")

            // Update the local user model in the session manager
            sessionManager.updateLocalUserPregnancyData(with: data)
            
            // Navigate to the next major onboarding screen
            navigateToNotifications = true

        } catch {
            print("Error saving onboarding data: \(error.localizedDescription)")
            errorMessage = "Failed to save your selections. Please try again."
        }
        
        isLoading = false
    }
}
