//
//  MoodActionCard.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 10/4/25.
//

import SwiftUI

struct MoodActionCard: View {
    let title: String
    let subtitle: String
    var emotion: String?
    var iconName: String?
    let lastLoggedDate: Date?
    let action: () -> Void

    @State private var isFlipped = false

    // ✅ Use one constant height (matches your EPDS card or flipped mood card)
    private let cardHeight: CGFloat = 180

    var body: some View {
        Button(action: action) {
            ZStack {
                // FRONT
                MoodCardFace(
                    title: title,
                    backgroundColor: .white
                ) {
                    DefaultPromptView(subtitle: subtitle)
                }
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0),
                                  axis: (x: 0, y: 1, z: 0))

                // BACK
                if let emotion, let iconName {
                    MoodCardFace(
                        title: title,
                        backgroundColor: Color.emotionBackground(for: emotion)
                    ) {
                        MoodCompletedView(emotion: emotion, iconName: iconName)
                    }
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -180),
                                      axis: (x: 0, y: 1, z: 0))
                }
            }
            .frame(height: cardHeight) // ✅ consistent height here
        }
        .buttonStyle(.plain)
        .onChange(of: emotion) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                isFlipped = (newValue != nil)
            }
        }
        .onAppear {
            // Flip if checked in today (within 24h)
            if let lastLoggedDate,
               let hours = Calendar.current.dateComponents([.hour], from: lastLoggedDate, to: Date()).hour,
               hours < 24 {
                isFlipped = (emotion != nil)
            } else {
                isFlipped = false
            }
        }
    }
}

// MARK: - Face Layout
struct MoodCardFace<Content: View>: View {
    let title: String
    let backgroundColor: Color
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.epilogue(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .padding([.top, .horizontal])

            Spacer(minLength: 0)

            content()
                .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180) // ✅ exact same constant height as main card
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Subviews
private struct DefaultPromptView: View {
    let subtitle: String
    var body: some View {
        VStack {
            ZStack{
                Circle()
                    .fill(Color("ThemeGreen"))
                    .frame(width: 40, height: 40)
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            Spacer()
            Spacer()
            Text(subtitle)
                .font(.epilogue(size: 20, weight: .bold))
                .foregroundColor(Color("ThemeGreen"))
            Spacer()
          
          
        }
    }
}

struct MoodCompletedView: View {
    let emotion: String
    let iconName: String

    var body: some View {
        VStack(spacing: 10) {
            Image(iconName) // Custom asset name (not SF Symbol)
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 70, height: 70)
                .padding(.bottom, 4)

            Text(emotion)
                .font(.epilogue(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    struct AnimationDemo: View {
        @State private var emotion: String? = "Startled"
        @State private var lastLoggedDate: Date? = Calendar.current.date(byAdding: .day, value: -10, to: Date())

        var body: some View {
            VStack {
                MoodActionCard(
                    title: "YOUR MOOD",
                    subtitle: "Check in",
                    emotion: emotion,
                    iconName: "startled",
                    lastLoggedDate: lastLoggedDate,
                    action: {}
                )
                Button("Toggle Emotion") {
                    if emotion == nil {
                        emotion = "Startled"
                        lastLoggedDate = Date()
                    } else {
                        emotion = nil
                        lastLoggedDate = nil
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
