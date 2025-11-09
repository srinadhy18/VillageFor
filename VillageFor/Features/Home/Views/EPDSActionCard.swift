//
//  EPDSActionCard.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 10/4/25.
//

import SwiftUI

struct EPDSActionCard: View {
    // MARK: - Properties
    
    // Data for the card
    let title: String
    let subtitle: String
    var score: Int?
    let scoreSubtitle: String
    let action: () -> Void
    
    // State for the animation
    @State private var isFlipped = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // --- Front of the Card (Prompt) ---
                EPDSCardFace(
                    title: title,
                    content: {
                        defaultPromptView(subtitle: subtitle)
                    }
                )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                // --- Back of the Card (Score) ---
                if let score = score {
                    EPDSCardFace(
                        title: title,
                        content: {
                            scoreView(score: score, subtitle: scoreSubtitle)
                        }
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                }
            }
        }
        .buttonStyle(.plain)
        // This watches for when the score appears and triggers the flip animation.
        .onChange(of: score) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isFlipped = true
                }
            } else if newValue == nil {
                isFlipped = false
            }
        }
        .onAppear {
            // Set initial state without animation
            isFlipped = (score != nil)
        }
    }
    
    // MARK: - Private View Builders
    
    private func scoreView(score: Int, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.epilogue(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.epilogue(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private func defaultPromptView(subtitle: String) -> some View {
        HStack {
            Text(subtitle)
                .font(.epilogue(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.title)
                .foregroundColor(Color("ThemeGreen"))
        }
    }
}


// MARK: - EPDSCardFace Helper
/// A helper view to build the common structure of a card face.
private struct EPDSCardFace<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.epilogue(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding([.top, .horizontal])
            
            Spacer()
            
            content
                .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    struct AnimationDemo: View {
        @State private var score: Int? = 17
        
        var body: some View {
            VStack {
                EPDSActionCard(
                    title: "WEEKLY ASSESSMENT",
                    subtitle: "Take quiz",
                    score: score,
                    scoreSubtitle: "Total Score",
                    action: {}
                )
                
                Button("Toggle Score") {
                    withAnimation {
                        if score == nil {
                            score = 17
                        } else {
                            score = nil
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
        }
    }
    
    return AnimationDemo()
}
