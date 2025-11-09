//
//  EPDSQuestion1ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion1ViewModel: ObservableObject {
    
    // The data model passed from the previous screen
    var assessment: EPDSAssessment
    
    let questionText = "I have been able to laugh and see the funny side of things"
    let answers = [
        EPDSAnswer(text: "As much as I always could", score: 0),
        EPDSAnswer(text: "Not quite as much now", score: 1),
        EPDSAnswer(text: "Definitely not as much now", score: 2),
        EPDSAnswer(text: "Not at all", score: 3)
    ]
    
    // State for navigation
    @Published var shouldNavigateToNext = false
    
    init(assessment: EPDSAssessment) {
        self.assessment = assessment
    }
    
    /// Saves the answer and triggers navigation
    func selectAnswer(score: Int) {
        assessment.answers[questionText] = score
        shouldNavigateToNext = true
    }
}