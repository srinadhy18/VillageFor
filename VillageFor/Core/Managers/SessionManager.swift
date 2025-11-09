//
//  SessionManager.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//
import Foundation
import FirebaseAuth
import Combine

@MainActor
class SessionManager: ObservableObject {

    @Published var currentUser: User?
    @Published var isTabBarHidden = false

    private var cancellables = Set<AnyCancellable>()
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
        setupFirebaseAuthListener()
    }

    
    func navigateToHome() {
        print("SessionManager: navigateToHome() called")
         NotificationCenter.default.post(name: .resetToHomeTab, object: nil)
         NotificationCenter.default.post(name: .navigateToHome, object: nil)
         print("SessionManager: Posted both notifications")
    }
    
    private func setupFirebaseAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            if let firebaseUser = user {
                // User is logged in, fetch their profile
                Task {
                    await self.fetchCurrentUserProfile(uid: firebaseUser.uid)
                }
            } else {
                // User is logged out, clear currentUser
                self.currentUser = nil
            }
        }
    }

    func fetchCurrentUserProfile(uid: String) async {
        do {
            self.currentUser = try await firestoreService.fetchUserProfile(uid: uid)
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
            self.currentUser = nil
        }
    }
    
    func updateLocalUserPregnancyData(with onboardingData: OnboardingData) {
         guard self.currentUser != nil else {
             print("⚠️ Warning: currentUser is nil. Cannot update local user model.")
             return
         }
         
         self.currentUser?.pregnancyStatus = onboardingData.pregnancyStatus?.rawValue
         self.currentUser?.isFirstPregnancy = (onboardingData.isFirstPregnancy == .yes)
         self.currentUser?.isPostpartum = (onboardingData.isPostpartum == .yes)
         self.currentUser?.postpartumWeeks = onboardingData.postpartumWeeks
         self.currentUser?.isFirstPostpartumExperience = (onboardingData.isFirstPostpartumExperience == .yes)
         self.currentUser?.mentalHealthProfessionalType = onboardingData.workingWithMentalHealthPro?.rawValue
         
         print("SessionManager's local currentUser has been updated with onboarding data.")
     }

    // represents a user who has completed onboarding, especially for existing users.
    func hasCompletedOnboarding(user: User) -> Bool {
        guard let firstName = user.firstName, !firstName.isEmpty,
              let _ = user.age,
              let _ = user.notificationPreferences else {
            return false
        }
        return true
    }

}


extension Notification.Name {
    static let navigateToHome = Notification.Name("navigateToHome")
    static let resetToHomeTab = Notification.Name("resetToHomeTab")
    static let moodCheckinCompleted = Notification.Name("moodCheckinCompleted")
    static let epdsAssessmentCompleted = Notification.Name("epdsAssessmentCompleted")
}
