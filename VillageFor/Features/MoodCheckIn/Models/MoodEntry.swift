//
//  MoodEntry.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/8/25.
//


import Foundation
import FirebaseFirestore
import SwiftUI

struct DailyCheckin: Identifiable, Codable {
    @DocumentID var id: String?
    var moodValue: Double?
    var energyValue: Double?
    var selectedEmotion: String?
    var journalText: String?
    var factors: [String]?
    let timestamp: Timestamp
    var checkInAffirmation: String?
    
    /// Optional alias
    var moodName: String? { selectedEmotion }

    /// Convert Firestore Timestamp → Swift Date
    var date: Date {
        timestamp.dateValue()
    }
}

// MARK: - Emotion-based helpers
extension DailyCheckin {
    /// Returns the soft pastel color for the selected emotion using Assets
    var moodColor: Color {
        Color.emotionColor(for: selectedEmotion ?? "")
    }

    /// Returns the darker accent variant for the selected emotion
    var moodDarkColor: Color {
        Color.emotionDarkColor(for: selectedEmotion ?? "")
    }

    /// Computed valence used for positive/negative mood analytics
    var valence: MoodValence {
        guard let emotion = selectedEmotion?.lowercased() else { return .neutral }

        // Group similar feelings by positivity
        if ["happy", "joyful", "calm", "grateful", "excited", "hopeful", "inspired", "content", "loved", "proud"].contains(where: { emotion.contains($0) }) {
            return .positive
        } else if ["sad", "angry", "fearful", "disgusted", "anxious", "stressed", "lonely", "depressed", "hurt"].contains(where: { emotion.contains($0) }) {
            return .negative
        } else {
            return .neutral
        }
    }
}

// MARK: - Mood Valence Enum
enum MoodValence: String, Codable {
    case positive, negative, neutral
}
