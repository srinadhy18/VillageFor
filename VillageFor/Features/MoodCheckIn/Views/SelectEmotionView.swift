//
//  SelectEmotionView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/19/25.
//


import SwiftUI

struct SelectEmotionView: View {
    @StateObject private var viewModel: SelectEmotionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmotion: String? = nil
    
    init(dailyCheckin: DailyCheckin) {
        _viewModel = StateObject(wrappedValue: SelectEmotionViewModel(dailyCheckin: dailyCheckin))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Describe your emotions")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Here are words that correspond to different moods. Select the one that feels most like you.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // Scrollable emotion list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.emotions, id: \.self) { emotion in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedEmotion = emotion
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    viewModel.selectEmotionAndContinue(emotion)
                                }
                            }
                        }) {
                            HStack {
                                Text(emotion)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if selectedEmotion == emotion {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("\(emotion)DarkColor"))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .background(Color("\(emotion)Color"))
                            .cornerRadius(16)
                            .overlay(                                                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedEmotion == emotion ? Color("\(emotion)DarkColor") : .clear,
                                    lineWidth: 2
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            NavigationLink(destination: FindEmotionView(dailyCheckin: viewModel.dailyCheckin)) {
                   Text("More Emotions")
                       .font(.headline)
                       .foregroundColor(.secondary)
                       .frame(maxWidth: .infinity)
               }
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        .navigationDestination(
            isPresented: $viewModel.shouldNavigateToJournalView
        ) {
            JournalView(dailyCheckin: viewModel.dailyCheckin)
        }
    }
}



#Preview {
    let sampleCheckin = DailyCheckin(selectedEmotion: "Astonished", timestamp: .init(date: Date()))
    
    return NavigationStack {
        SelectEmotionView(dailyCheckin: sampleCheckin)
    }
}
