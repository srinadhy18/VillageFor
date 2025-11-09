//
//  EPDSIntroductionView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//



import SwiftUI
struct EPDSIntroductionView: View {
    // This view now needs to accept the assessment object
    let assessment: EPDSAssessment
    
    @StateObject private var viewModel = EPDSIntroductionViewModel()
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("ThemeGreen").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Start your EPDS-US assessment")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("The Edinburgh Postnatal Depression Scale (EPDS-US) is a short questionnaire that helps check for signs of depression in new moms. It asks about your feelings over the past week to give a picture of your emotional health.\n\nThis is not a test to diagnose depression but a tool to help you notice any symptoms and help figure out what to do. If you're worried about your score, talking to a doctor or counselor can be a good next step.")
                    .lineSpacing(6)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                CheckboxView(
                    isChecked: Binding(
                        // We use a custom binding to invert the logic, since the property is "shouldShow"
                        get: { !viewModel.shouldShowAgain },
                        set: { viewModel.shouldShowAgain = !$0 }
                    ),
                    label: "Don't show this again"
                )
                .foregroundColor(.white)
            }
            .padding(30)
            
            Button("Start assessment") {
                viewModel.startAssessment()
            }
            .buttonStyle(.primary) // Assuming you have a primary button style that works on a dark background
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar(foregroundColor: .white)
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldStartAssessment) {
            // Navigate to the first question, passing the assessment object along
            EPDSQuestion1View(assessment: assessment)
                .environmentObject(sessionManager)
        }
    }
}

#Preview {
    NavigationStack {
        // The preview needs a sample assessment object to work
        let sampleAssessment = EPDSAssessment(timestamp: .init(date: Date()))
        EPDSIntroductionView(assessment: sampleAssessment)
            .environmentObject(SessionManager())
    }
}
