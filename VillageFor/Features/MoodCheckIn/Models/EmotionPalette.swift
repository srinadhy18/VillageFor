//
//  EmotionPalette.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/2/25.
//

import Foundation

struct EmotionPalette {
    static let categories: [EmotionCategory] = [
        EmotionCategory(name: "Happy", color: "Happy", emotions: ["Happy", "Joyful", "Curious", "Interested", "Creative", "Hopeful", "Inspired"]),
        EmotionCategory(name: "Calm", color: "Calm", emotions: ["Calm", "Content", "Loving", "Peaceful", "Satisfied", "Trusting", "Free"]),
        EmotionCategory(name: "Grateful", color: "Grateful", emotions: ["Grateful", "Accepted", "Loved", "Respected", "Valued", "Proud", "Powerful"]),
        EmotionCategory(name: "Excited", color: "Startled", emotions: ["Startled", "Amazed", "Excited", "Astonished", "Awed", "Eager", "Energetic"]),
        EmotionCategory(name: "Sad", color: "Sad", emotions: ["Sad", "Lonely", "Vulnerable", "Guilty", "Stressed", "Depressed", "Hurt"]),
        EmotionCategory(name: "Disgusted", color: "Disgusted", emotions: ["Disgusted", "Disappointed", "Disapproving", "Repelled", "Judgmental", "Embarrassed", "Appalled"]),
        EmotionCategory(name: "Fearful", color: "Fearful", emotions: ["Fearful", "Insecure", "Weak", "Anxious", "Rejected", "Threatened", "Overwhelmed"]),
        EmotionCategory(name: "Angry", color: "Angry", emotions: ["Angry", "Frustrated", "Critical", "Let down", "Distant", "Frustated", "Bitter"])
    ]
}

// MARK: - Supporting Models
/// A category of emotions used for grouping and color mapping.
struct EmotionCategory {
    let name: String
    let color: String // Matches color name in Assets (e.g. "HappyColor")
    let emotions: [String]
}
