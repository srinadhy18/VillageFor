//
//  EPDSQuestion1View.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import SwiftUI

struct EPDSQuestion1View: View {
    
    @StateObject private var viewModel: EPDSQuestion1ViewModel
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedAnswerId: UUID?
    
    init(assessment: EPDSAssessment) {
        _viewModel = StateObject(wrappedValue: EPDSQuestion1ViewModel(assessment: assessment))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
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
            EPDSQuestion2View(assessment: viewModel.assessment)
                .environmentObject(sessionManager)
        }
    }
    
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
        EPDSQuestion1View(assessment: sampleAssessment)
            .environmentObject(SessionManager())
    }
}
