//
//  EPDSQuestion6ViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//



import Foundation

@MainActor
class EPDSQuestion6ViewModel: ObservableObject {
    
    var assessment: EPDSAssessment
    
    let questionText = "I have felt overwhelmed"
    let answers = [
        EPDSAnswer(text: "Yes, most of the time I haven't been able to cope at all", score: 3),
        EPDSAnswer(text: "Yes, sometimes I haven't been coping as well as usual", score: 2),
        EPDSAnswer(text: "No, most of the time I have coped quite well", score: 1),
        EPDSAnswer(text: "No, I have been coping as well as ever", score: 0)
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
