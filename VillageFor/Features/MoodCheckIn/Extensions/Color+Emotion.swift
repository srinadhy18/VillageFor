//
//  Color+Emotion.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/2/25.
//

import SwiftUICore


// MARK: - Global Color Helpers
extension Color {
    /// Returns the pastel background color for a given emotion.
    static func emotionColor(for emotion: String) -> Color {
        let normalized = emotion.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        if let category = EmotionPalette.categories.first(where: { $0.emotions.contains(normalized) }) {
            return Color("\(category.color)Color")
        } else {
            return Color.gray.opacity(0.2) // fallback
        }
    }
    
    /// Returns the darker accent color for a selected state.
    static func emotionDarkColor(for emotion: String) -> Color {
        let normalized = emotion.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        if let category = EmotionPalette.categories.first(where: { $0.emotions.contains(normalized) }) {
            return Color("\(category.color)DarkColor")
        } else {
            return Color.gray
        }
    }
    
    /// Returns a dynamic background color for a given emotion based on its category.
    static func emotionBackground(for emotion: String) -> Color {
        let normalized = emotion.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        if let category = EmotionPalette.categories.first(where: { $0.emotions.contains(normalized) }) {
            return Color("\(category.color)Color")
        } else {
            return Color.white // fallback to neutral background
        }
    }
}
