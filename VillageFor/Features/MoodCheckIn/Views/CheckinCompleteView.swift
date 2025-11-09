//
//  CheckinCompleteView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 8/20/25.
//


import SwiftUI

struct CheckinCompleteView: View {
    
    // This dismiss action will close the entire check-in sheet.
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    // State to control the visibility of the finish button for the animation.
    @State private var isFinishButtonVisible = false
    @State private var isFlipped = false
    
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image("Splash_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .scaleEffect(x: isFlipped ? -1 : 1, y: 1) // Apply the scale
                .onAppear {
                    withAnimation(.easeInOut(duration: 1)) {
                        isFlipped.toggle()
                    }
                }
            
            
            // Confirmation text
            Text("Check-in complete")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Today I embrace all that I am.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Finish") {
                // This single dismiss call will close the entire check-in flow.
                NotificationCenter.default.post(name: .moodCheckinCompleted, object: nil)
                sessionManager.navigateToHome()
            }
            .buttonStyle(.primary)
            // The button's visibility is controlled by our state variable.
            .opacity(isFinishButtonVisible ? 1 : 0)
            
        }
        .padding()
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // When the view appears, wait for 1.5 seconds, then fade in the button.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isFinishButtonVisible = true
                }
            }
        }
    }
}

#Preview {
    CheckinCompleteView()
}
