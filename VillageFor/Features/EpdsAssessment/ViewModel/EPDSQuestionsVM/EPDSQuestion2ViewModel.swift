//
//  EPDSQuestion2ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion2ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "I have looked forward to things"
    let answers = [
        EPDSAnswer(text: "As much as I ever did", score: 0),
        EPDSAnswer(text: "Somewhat less than I used to", score: 1),
        EPDSAnswer(text: "Definitely less than I used to", score: 2),
        EPDSAnswer(text: "Hardly at all", score: 3)
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