//
//  SelectEmotionsViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/19/25.
//

import Foundation

@MainActor
class SelectEmotionViewModel: ObservableObject {
    
    // The check-in data passed from the previous screen
    var dailyCheckin: DailyCheckin
    
    @Published var shouldNavigateToJournalView = false
    
    // Primary emotions for the main selection screen
    let emotions = [
        "Happy",
        "Calm",
        "Grateful",
        "Startled",
        "Sad",
        "Disgusted",
        "Fearful",
        "Angry"
    ]
    
    init(dailyCheckin: DailyCheckin) {
        self.dailyCheckin = dailyCheckin
    }
    
    /// Called when the user picks an emotion
    func selectEmotionAndContinue(_ emotion: String) {
        dailyCheckin.selectedEmotion = emotion
        shouldNavigateToJournalView = true
    }
}
