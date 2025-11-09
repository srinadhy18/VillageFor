//
//  FindEmotionViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/2/25.
//

import Foundation
import SwiftUI

// MARK: - ViewModel
@MainActor
final class FindEmotionViewModel: ObservableObject {
    
    // This holds the check-in data passed from the previous screen.
    var dailyCheckin: DailyCheckin
    
    // MARK: - Published State
    @Published var searchText = ""
    @Published var selectedEmotion: String?
    @Published var shouldNavigateToJournal = false
    
    /// Determines if the Continue button should be enabled.
    var isContinueButtonEnabled: Bool {
        selectedEmotion != nil
    }
    
    // MARK: - Init
    init(dailyCheckin: DailyCheckin) {
        self.dailyCheckin = dailyCheckin
    }
    
    // MARK: - Logic
    
    /// Filters the emotions within a specific category based on the search text.
    func filteredEmotions(for category: EmotionCategory) -> [String] {
        if searchText.isEmpty {
            return category.emotions
        } else {
            return category.emotions.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    /// Toggles the user's emotion selection.
    func selectEmotion(_ emotion: String) {
        selectedEmotion = (selectedEmotion == emotion) ? nil : emotion
    }
    
    /// Updates the check-in object and triggers navigation to the JournalView.
    func continueToJournal() {
        if let emotion = selectedEmotion {
            dailyCheckin.selectedEmotion = emotion
            shouldNavigateToJournal = true
        }
    }
    
    /// Returns the emotion category for a given emotion.
    private func getCategory(for emotion: String) -> EmotionCategory? {
        return EmotionPalette.categories.first { $0.emotions.contains(emotion) }
    }
    
    /// Returns the appropriate color for an emotion (used internally if needed).
    func color(for emotion: String) -> Color {
        guard let category = getCategory(for: emotion) else { return .gray.opacity(0.3) }
        return Color("\(category.color)Color")
    }
}
