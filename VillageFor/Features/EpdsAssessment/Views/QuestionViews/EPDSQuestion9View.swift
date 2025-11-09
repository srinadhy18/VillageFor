//
//  EPDSQuestion9View.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import SwiftUI

struct EPDSQuestion9View: View {
    
    @StateObject private var viewModel: EPDSQuestion9ViewModel
    @EnvironmentObject var sessionManager: SessionManager
    
    // This local state is used to manage the button's selection animation.
    @State private var selectedAnswerId: UUID?
    
    init(assessment: EPDSAssessment) {
        _viewModel = StateObject(wrappedValue: EPDSQuestion9ViewModel(assessment: assessment))
    }
    
    var body: some View {
        // Use a ZStack to manage the background color correctly.
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            // This root VStack has no padding.
            VStack(spacing: 0) {
                ScrollView {
                    // This inner VStack contains all the padded content.
                    VStack(alignment: .leading, spacing: 20) {
                        Text(viewModel.questionText)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .padding(.bottom, 20)

                        VStack(spacing: 12) {
                            ForEach(viewModel.answers) { answer in
                                EPDSOptionButton(
                                    text: answer.text,
                                    isSelected: selectedAnswerId == answer.id
                                ) {
                                    handleAnswerSelection(answer)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Image("epds_bottom_pattern")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToNext) {
            EPDSQuestion10View(assessment: viewModel.assessment)
                .environmentObject(sessionManager)
        }
    }
    
    /// This function handles the UI animation and tells the ViewModel to proceed.
    private func handleAnswerSelection(_ answer: EPDSAnswer) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedAnswerId = answer.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.selectAnswer(score: answer.score)
        }
    }
}

#Preview {
    NavigationStack {
        let sampleAssessment = EPDSAssessment(timestamp: .init(date: Date()))
        EPDSQuestion9View(assessment: sampleAssessment)
            .environmentObject(SessionManager())
    }
}
