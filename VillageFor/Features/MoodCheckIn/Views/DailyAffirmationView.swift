//
//  DailyAffirmationView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 8/20/25.
//

import SwiftUI

struct DailyAffirmationView: View {
    
    @StateObject private var viewModel: DailyAffirmationViewModel
    
    init(dailyCheckin: DailyCheckin) {
        _viewModel = StateObject(wrappedValue: DailyAffirmationViewModel(dailyCheckin: dailyCheckin))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily affirmations")
                .font(.largeTitle).fontWeight(.bold)
            
            // "Fill in the blank" TextField
            HStack {
                Text("My")
                TextField("___", text: $viewModel.customWord)
                Text("is my greatest quality as a mother.")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            // Selectable word buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.affirmationWords, id: \.self) { word in
                        Button(word) { viewModel.customWord = word }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                    }
                }
            }
            
            // "Remind Yourself" card
            VStack(alignment: .leading, spacing: 8) {
                Text("REMIND YOURSELF")
                    .font(.caption).fontWeight(.bold)
                Text("I am the person my child trusts and loves the most.")
                    .font(.title3)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("ThemeGreen").opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(20)
            
            Spacer()
            
            Button("Continue") {
                Task {
                    await viewModel.saveFinalCheckin()
                }
            }
            .buttonStyle(.primary)
        }
        .padding()
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            // ... Close button ...
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToCompletion) {
            CheckinCompleteView()
        }
    }
}

#Preview {
    // 1. Create a sample DailyCheckin object to pass to the view's initializer.
    let sampleCheckin = DailyCheckin(timestamp: .init(date: Date()))
    
    // 2. Wrap the view in a NavigationStack so the toolbar is visible.
    return NavigationStack {
        DailyAffirmationView(dailyCheckin: sampleCheckin)
    }
}
