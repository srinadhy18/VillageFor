//
//  EPDSQuestion8ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion8ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "I have felt sad or miserable"
    let answers = [
        EPDSAnswer(text: "Yes, most of the time", score: 3),
        EPDSAnswer(text: "Yes, sometimes", score: 2),
        EPDSAnswer(text: "Not very often", score: 1),
        EPDSAnswer(text: "No, not at all", score: 0)
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