//
//  EPDSQuestion10ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import Foundation

@MainActor
class EPDSQuestion10ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "The thought of harming myself has occured to me"
    let answers = [
        EPDSAnswer(text: "Yes, quite often", score: 3),
        EPDSAnswer(text: "Sometimes", score: 2),
        EPDSAnswer(text: "Hardly ever", score: 1),
        EPDSAnswer(text: "Never", score: 0)
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