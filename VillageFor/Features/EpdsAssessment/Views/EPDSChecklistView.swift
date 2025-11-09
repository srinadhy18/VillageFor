//
//  EPDSChecklistView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//


import SwiftUI

struct EPDSChecklistView: View {
    
    @StateObject private var viewModel: EPDSChecklistViewModel
    @EnvironmentObject var sessionManager: SessionManager
    
    init(assessment: EPDSAssessment) {
        _viewModel = StateObject(wrappedValue: EPDSChecklistViewModel(assessment: assessment))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // --- Header ---
                Text("Additional experiences checklist")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Here are some other ways people describe symptoms or experiences that may relate to emotional health and well-being. Please let us know any of these you have been experiencing:")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // --- Checklist Items ---
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.checklistItems, id: \.self) { item in
                        CheckboxRow(
                            label: item,
                            isSelected: viewModel.selectedExperiences.contains(item),
                            action: { viewModel.toggleExperience(item) }
                        )
                    }
                }
                
                Spacer(minLength: 40)
                
                Button("Continue") {
                    Task {
                        await viewModel.saveAssessment()
                        viewModel.navigateToResults = true
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
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
//         --- Navigation Logic ---
                .navigationDestination(isPresented: $viewModel.navigateToResults) {
                    // This is a placeholder for the results screen you will build next.
                    EPDSResultsView(assessment: viewModel.assessment)
                        .environmentObject(sessionManager)
                }
    }
}

// A helper view for each row in the checklist
private struct CheckboxRow: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? Color("EPDSGreen") : .secondary)
                
                
                Text(label)
                    .foregroundColor(.primary)
//                    .lineLimit(1) // Force single line
//                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true) // Allow text to use available width
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}


#Preview {
    NavigationStack {
        let sampleAssessment = EPDSAssessment(timestamp: .init(date: Date()))
        EPDSChecklistView(assessment: sampleAssessment)
            .environmentObject(SessionManager())
    }
}
