//
//  DailyAffirmationViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 8/20/25.
//

import Foundation
import FirebaseAuth

@MainActor
class DailyAffirmationViewModel: ObservableObject {
    
    // This holds the check-in data from all the previous screens.
    var dailyCheckin: DailyCheckin
    
    // Data for the view
    let affirmationWords = ["Strength", "Empathy", "Love", "Kindness", "Tenacity"]
    
    // State for user input
    @Published var customWord = ""
    
    // This flag will trigger navigation to the final completion screen.
    @Published var shouldNavigateToCompletion = false
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(dailyCheckin: DailyCheckin, firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.dailyCheckin = dailyCheckin
        self.firestoreService = firestoreService
    }
    
    /// This is the final save function for the entire check-in flow.
    func saveFinalCheckin() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 1. Create the final affirmation string.
        let finalAffirmation = "My \(customWord) is my greatest quality as a mother."
        dailyCheckin.checkInAffirmation = finalAffirmation
        
        do {
            // 2. Save the completed object to Firestore.
            try await firestoreService.saveDailyCheckin(uid: uid, checkin: dailyCheckin)
            print("Final check-in saved successfully!")
            
            // 3. Set the flag to true to navigate to the completion screen.
            shouldNavigateToCompletion = true
            
        } catch {
            print("Error saving final check-in: \(error.localizedDescription)")
        }
    }
}
