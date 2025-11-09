//
//  EPDSIntroductionViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import Foundation

@MainActor
class EPDSIntroductionViewModel: ObservableObject {
    @Published var shouldStartAssessment = false
    
    // A computed property to get/set the value from UserDefaults
    var shouldShowAgain: Bool {
        get { UserDefaults.standard.shouldShowEPDSIntroduction }
        set { UserDefaults.standard.shouldShowEPDSIntroduction = newValue }
    }
    
    func startAssessment() {
        shouldStartAssessment = true
    }
}
