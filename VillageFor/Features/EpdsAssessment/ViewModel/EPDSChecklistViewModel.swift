//
//  EPDSChecklistViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class EPDSChecklistViewModel: ObservableObject {
    
    @Published var assessment: EPDSAssessment
    @Published var selectedExperiences: Set<String> = []
    @Published var navigateToResults = false
    private let firestoreService: FirestoreServiceProtocol
    
    let checklistItems = [
        "Feeling restless or unable to sit still",
        "Having trouble concentrating or making decisions",
        "Feeling unusually tired or lacking energy",
        "Having changes in appetite or sleep patterns",
        "Feeling disconnected from your baby or partner",
        "Having thoughts of harming yourself or others"
        // Add more checklist items as needed
    ]
    
    init(assessment: EPDSAssessment, firestoreService: FirestoreServiceProtocol = FirestoreService()) {
           self.assessment = assessment
           self.firestoreService = firestoreService
       }
    
    func toggleExperience(_ experience: String) {
        if selectedExperiences.contains(experience) {
            selectedExperiences.remove(experience)
        } else {
            selectedExperiences.insert(experience)
        }
    }
    
    func saveAssessment() async {
        // CRITICAL: Calculate total score before saving
        calculateTotalScore()
        
        // Store checklist responses
        assessment.additionalExperiences = Array(selectedExperiences)
        
        // Save to Firestore
        do {
            // Your Firestore save logic here
            try await saveToFirestore()
            // After successful save, trigger navigation
                self.navigateToResults = true
        } catch {
            print("Error saving assessment: \(error)")
            // Handle error - maybe show alert
        }
    }
    
    /// Calculate the total EPDS score from individual question answers
    private func calculateTotalScore() {
        // Sum up all the scores from the answers dictionary
        let total = assessment.answers.values.reduce(0, +)
        assessment.totalScore = total
        
        print("Calculated EPDS total score: \(total)")
        print("Individual answers: \(assessment.answers)")
    }
    
    private func saveToFirestore() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "EPDSError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        print("Saving assessment with total score: \(assessment.totalScore)")
        
        // Actually save to Firestore using your FirestoreService
        try await firestoreService.saveEPDSAssessment(uid: uid, assessment: assessment)
        
        print("EPDS assessment saved to Firestore successfully")
    }
}

//@MainActor
//class EPDSChecklistViewModel: ObservableObject {
//
//    // This holds the assessment data from the previous 10 questions.
//    public var assessment: EPDSAssessment
//
//    // The list of options to display on the checklist.
//    let checklistItems: [String] = [
//        "Scary, intrusive, or repetitive thoughts",
//        "Feeling irritable, agitated, or overstimulated",
//        "Headaches",
//        "Feelings of anger or rage",
//        "Heart racing",
//        "Feeling stressed",
//        "Feeling ‘off’ or not like yourself",
//        "Feeling like you are failing",
//        "Difficulty concentrating or making decisions",
//        "Changes in appetite",
//        "Incontinence - leaking urine or stool",
//        "Numbness or tingling",
//        "Pain",
//        "Fatigue",
//        "Personal or family mental health history"
//    ]
//
//    // This tracks which items the user has selected.
//    @Published var selectedExperiences = Set<String>()
//
//    // This flag will trigger navigation to the results screen.
//    @Published var navigateToResults = false
//
//    private let firestoreService: FirestoreServiceProtocol
//
//    init(assessment: EPDSAssessment, firestoreService: FirestoreServiceProtocol = FirestoreService()) {
//        self.assessment = assessment
//        self.firestoreService = firestoreService
//    }
//
//    /// Adds or removes an experience from the selected set.
//    func toggleExperience(_ experience: String) {
//        if selectedExperiences.contains(experience) {
//            selectedExperiences.remove(experience)
//        } else {
//            selectedExperiences.insert(experience)
//        }
//    }
//
//    /// This is the final save function for the entire assessment.
//    func saveAssessment() async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        // 1. Add the selected experiences to the assessment object.
//        assessment.additionalExperiences = Array(self.selectedExperiences)
//
//        do {
//            // 2. Save the completed assessment to Firestore.
//            try await firestoreService.saveEPDSAssessment(uid: uid, assessment: assessment)
//            print("Successfully saved complete EPDS Assessment.")
//
//            // 3. Trigger navigation to the results screen.
//            navigateToResults = true
//
//        } catch {
//            print("Error saving EPDS Assessment: \(error.localizedDescription)")
//            // Optionally, you could set an error message here to display to the user.
//        }
//
//        DispatchQueue.main.async {
//            self.navigateToResults = true
//            print("Setting the navigateToResults to true")
//        }
//    }
//}

//
//
//"Scary, intrusive, or repetitive thoughts",
//"Feeling irritable, agitated, or overstimulated",
//"Headaches",
//"Feelings of anger or rage",
//"Heart racing",
//"Feeling stressed",
//"Feeling ‘off’ or not like yourself",
//"Feeling like you are failing",
//"Difficulty concentrating or making decisions",
//"Changes in appetite",
//"Incontinence - leaking urine or stool",
//"Numbness or tingling",
//"Pain",
//"Fatigue",
//"Personal or family mental health history"
