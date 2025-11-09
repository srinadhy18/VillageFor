//
//  JournalView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/21/25.
//


import SwiftUI

struct JournalView: View {
    
    @StateObject private var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(dailyCheckin: DailyCheckin) {
        _viewModel = StateObject(wrappedValue: JournalViewModel(dailyCheckin: dailyCheckin))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Today I'm feeling...")
                    .font(.largeTitle).fontWeight(.bold)
                
                // Emotion Card
                EmotionDisplayCard(emotion: viewModel.emotion, icon: viewModel.emotionIcon, backgroundColor: viewModel.emotionColor)
                
                // Journal Text Editor
                TextEditor(text: $viewModel.journalText)
                    .frame(height: 150)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        Text("What made you feel \(viewModel.emotion.lowercased())?")
                            .foregroundColor(.secondary)
                            .padding(16)
                            .opacity(viewModel.journalText.isEmpty ? 1 : 0),
                        alignment: .topLeading
                    )
                
                // Prompt Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.prompts, id: \.self) { prompt in
                            Button(prompt) { viewModel.selectPrompt(prompt) }
                                .buttonStyle(.bordered)
                                .tint(.gray)
                        }
                    }
                }
                
                // Factors Section
                Text("Choose any that apply").font(.title2).fontWeight(.bold)
                FactorGridView(
                    allFactors: viewModel.allFactors,
                    selectedFactors: $viewModel.selectedFactors,
                    toggleAction: viewModel.toggleFactor
                )
                
                Spacer(minLength: 40)
                
                Button("Continue") {
                    Task {
                        viewModel.continueTapped()
                    }
                }
                .buttonStyle(.primary)
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            
            // Close button
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToAffirmations) {
           
            DailyAffirmationView(dailyCheckin: updatedCheckin)
        }
    }
    private var updatedCheckin: DailyCheckin {
        var checkin = viewModel.dailyCheckin
        checkin.journalText = viewModel.journalText
        checkin.factors = Array(viewModel.selectedFactors)
        return checkin
    }
    
}
#Preview {
    // The preview needs a sample DailyCheckin object to work
    let sampleCheckin = DailyCheckin(selectedEmotion: "Astonished", timestamp: .init(date: Date()))
    
    return NavigationStack {
        JournalView(dailyCheckin: sampleCheckin)
    }
}
