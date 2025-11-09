//
//  JournalViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/21/25.
//

import Foundation
import SwiftUICore

@MainActor
class JournalViewModel: ObservableObject {
    
    // This property holds the check-in data from the previous screens lets pass same to daily affirmations page.
     var dailyCheckin: DailyCheckin
    
    var emotion: String {
        dailyCheckin.selectedEmotion ?? "feeling"
    }
    
    // Data for the view
    let prompts: [String]
    let allFactors = ["Better sleep", "Journaled", "Meditated", "Baby blues", "Therapy", "Medication"]
    
    // State for user input
    @Published var journalText = ""
    @Published var selectedFactors = Set<String>()
    
    
    @Published var shouldNavigateToAffirmations = false
    
    
    // The initializer now takes the DailyCheckin object and the service.
    init(dailyCheckin: DailyCheckin) {
        self.dailyCheckin = dailyCheckin
        
        // Customize prompts based on the selected emotion
        let emotionWord = (dailyCheckin.selectedEmotion ?? "feeling").lowercased()
        self.prompts = ["I'm \(emotionWord) that...", "In this moment...", "I felt \(emotionWord) when..."]
    }
    
    // Appends a prompt to the journal text
    func selectPrompt(_ prompt: String) {
        // Add a space if the text field isn't empty
        if !journalText.isEmpty {
            journalText += " "
        }
        journalText += prompt
    }
    
    // Adds or removes a factor from the selected set
    func toggleFactor(_ factor: String) {
        if selectedFactors.contains(factor) {
            selectedFactors.remove(factor)
        } else {
            selectedFactors.insert(factor)
        }
    }
    
    func continueTapped() {
        shouldNavigateToAffirmations = true
    }
}

extension JournalViewModel {
    //Change the images here for emotion icons.
    var emotionIcon: String {
        switch emotion.lowercased() {
        case "happy", "joyful", "curious", "interested", "creative", "hopeful", "inspired":
            return "sun.max.fill"
        case "calm", "content", "loving", "peaceful", "satisfied", "trusting", "free":
            return "leaf.fill"
        case "grateful", "accepted", "loved", "respected", "valued", "proud", "powerful":
            return "heart.circle.fill"
        case "startled", "amazed", "excited", "astonished", "awed", "eager", "energetic":
            return "startled"
        case "sad", "lonely", "vulnerable", "guilty", "stressed", "depressed", "hurt":
            return "cloud.rain.fill"
        case "fearful", "insecure", "weak", "anxious", "rejected", "threatened", "overwhelmed":
            return "exclamationmark.triangle.fill"
        case "angry", "frustrated", "critical", "let down", "distant", "bitter":
            return "flame.fill"
        case "disgusted", "disappointed", "disapproving", "repelled", "judgmental", "embarrassed", "appalled":
            return "xmark.octagon.fill"
        default:
            return "startled"
        }
    }
    
    var emotionColor: Color {
        Color("\(emotion)Color") // "HappyColor", "SadColor"
    }
}
