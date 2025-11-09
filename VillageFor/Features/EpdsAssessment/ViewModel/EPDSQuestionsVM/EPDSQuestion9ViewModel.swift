//
//  EPDSQuestion9ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion9ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "I have felt so unhappy that I have been crying"
    let answers = [
        EPDSAnswer(text: "Yes, most of the time", score: 3),
        EPDSAnswer(text: "Yes, sometimes", score: 2),
        EPDSAnswer(text: "Only occasionally", score: 1),
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