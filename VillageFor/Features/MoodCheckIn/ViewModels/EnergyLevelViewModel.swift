//
//  EnergyLevelViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/8/25.
//

import Foundation


@MainActor
class EnergyLevelViewModel: ObservableObject {
    
    // The slider value, from 0.0 (bottom) to 1.0 (top)
    var dailyCheckin: DailyCheckin
    @Published var energyValue: Double = 0.5
    @Published var shouldNavigateToSelectAnEmotion = false
    
    init(dailyCheckin: DailyCheckin) {
           self.dailyCheckin = dailyCheckin
       }
    

    func contiueTapped() {
        shouldNavigateToSelectAnEmotion = true
        print("Navigate to Select an Emotion")
    }
    
}
