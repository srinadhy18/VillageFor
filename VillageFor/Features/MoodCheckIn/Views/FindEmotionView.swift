//
//  FindEmotionView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/2/25.
//

import SwiftUI

struct FindEmotionView: View {
    
    @StateObject private var viewModel: FindEmotionViewModel
    
    init(dailyCheckin: DailyCheckin) {
        _viewModel = StateObject(wrappedValue: FindEmotionViewModel(dailyCheckin: dailyCheckin))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Title
            Text("Find your emotion")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search", text: $viewModel.searchText)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal)
            
            // Emotion grid – horizontal list of vertical emotion columns
            ScrollView([.horizontal], showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(EmotionPalette.categories, id: \.name) { category in
                        let emotions = viewModel.filteredEmotions(for: category)
                        
                        if !emotions.isEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 12) {
                                    ForEach(Array(emotions.enumerated()), id: \.element) { index, emotion in
                                        EmotionColumnButton(
                                            emotion: emotion,
                                            isSelected: viewModel.selectedEmotion == emotion,
                                            baseColor: Color.emotionColor(for: emotion)
                                                .opacity(opacityForIndex(index, total: emotions.count)),
                                            selectedBorderColor: Color.emotionDarkColor(for: emotion),
                                            action: {
                                                viewModel.selectEmotion(emotion)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Continue button
            Button("Continue") {
                viewModel.continueToJournal()
            }
            .buttonStyle(.primary)
            .disabled(!viewModel.isContinueButtonEnabled)
            .padding()
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        // Navigate to JournalView when emotion is selected
        .navigationDestination(isPresented: $viewModel.shouldNavigateToJournal) {
            JournalView(dailyCheckin: viewModel.dailyCheckin)
        }
    }
}

// Calculates progressive opacity for emotion tiles (top = dark, bottom = light)
private func opacityForIndex(_ index: Int, total: Int) -> Double {
    let minOpacity: Double = 0.3
    let maxOpacity: Double = 1.0
    if total == 1 { return maxOpacity }
    let step = (maxOpacity - minOpacity) / Double(total - 1)
    return maxOpacity - (Double(index) * step)
}

// Emotion button used in each vertical column
private struct EmotionColumnButton: View {
    let emotion: String
    let isSelected: Bool
    let baseColor: Color
    let selectedBorderColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(emotion)
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
                .frame(width: 150, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(baseColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? selectedBorderColor : Color.clear, lineWidth: 10)
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: isSelected)
    }
}

// Preview
#Preview {
    let sampleCheckin = DailyCheckin(timestamp: .init(date: Date()))
    return NavigationStack {
        FindEmotionView(dailyCheckin: sampleCheckin)
            .environmentObject(SessionManager())
    }
}
