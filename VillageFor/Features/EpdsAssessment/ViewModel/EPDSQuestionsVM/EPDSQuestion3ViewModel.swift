//
//  EPDSQuestion3ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion3ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "I have blamed myself when things went wrong"
    // Note: The scoring for this question is reversed.
    let answers = [
        EPDSAnswer(text: "Yes, most of the time", score: 3),
        EPDSAnswer(text: "Yes, some of the time", score: 2),
        EPDSAnswer(text: "Not very often", score: 1),
        EPDSAnswer(text: "No, never", score: 0)
    ]
    
    @Published var shouldNavigateToNext = false
    
    init(assessment: EPDSAssessment) {
        self.assessment = assessment
    }
    
    func selectAnswer(score: Int) {
        assessment.answers[questionText] = score
        shouldNavigateToNext = true
    }
}