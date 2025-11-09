//
//  EPDSQuestion.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import Foundation
import FirebaseFirestore

struct EPDSAssessment: Identifiable, Codable {
    @DocumentID var id: String?
    var answers: [String: Int] = [:]
    var totalScore: Int = 0;
    let timestamp: Timestamp
    var additionalExperiences: [String]?
}

// In your EPDSAssessment model
extension EPDSAssessment {
    static func previewSample(score: Int = 17) -> EPDSAssessment {
        var assessment = EPDSAssessment(timestamp: .init(date: Date()))
        assessment.totalScore = score
        return assessment
    }
}


struct EPDSQuestion: Identifiable {
    let id = UUID()
    let text: String
    let answers: [EPDSAnswer]
}

struct EPDSAnswer: Identifiable {
    let id = UUID()
    let text: String
    let score: Int
}
