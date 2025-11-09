////
////  ActionCard.swift
////  VillageFor
////
////  Created by Srinadh Tanugonda on 7/2/25.
////
//
//import SwiftUI
//
//enum CardType {
//    case epds
//    case mood
//}
//
//// MARK: - ActionCard
//struct ActionCard: View {
//    let id: CardType
//    let title: String
//    let subtitle: String
//    let score: Int?        // Optional score
//    let scoreSubtitle: String?
//    let moodIcon: String?  // Optional mood icon
//    let action: () -> Void
//    
//    
//    @Binding var flippedCard: CardType?   
//    var body: some View {
//        Button(action: action) {
//            FlipCard(
//                front: CardContent(
//                    title: title,
//                    subtitle: subtitle,
//                    score: nil,
//                    moodIcon: moodIcon,
//                    isShowingScore: false
//                ),
//                back: CardContent(
//                    title: title,
//                    subtitle: scoreSubtitle ?? "Total Score",
//                    score: score,
//                    moodIcon: moodIcon,
//                    isShowingScore: true
//                ),
//                flipped: flippedCard == id
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//        .onChange(of: score) { oldValue, newValue in
//            // 🔑 Auto-flip EPDS when score first appears
//            if id == .epds, oldValue == nil, newValue != nil {
//                withAnimation(.easeInOut(duration: 0.9)) {
//                    flippedCard = .epds
//                }
//            }
//            // Reset if score cleared
//            if id == .epds, newValue == nil {
//                flippedCard = nil
//            }
//        }
//    }
//}
//
//// MARK: - FlipCard container
//private struct FlipCard<Front: View, Back: View>: View {
//    let front: Front
//    let back: Back
//    let flipped: Bool
//    
//    var body: some View {
//        ZStack {
//            front
//                .opacity(flipped ? 0 : 1)
//                .rotation3DEffect(.degrees(flipped ? 180 : 0),
//                                  axis: (x: 0, y: 1, z: 0),
//                                  perspective: 0.8)
//            
//            back
//                .opacity(flipped ? 1 : 0)
//                .rotation3DEffect(.degrees(flipped ? 0 : -180),
//                                  axis: (x: 0, y: 1, z: 0),
//                                  perspective: 0.8)
//        }
//    }
//}
//
//// MARK: - Card Content View
//private struct CardContent: View {
//    let title: String
//    let subtitle: String
//    let score: Int?
//    let moodIcon: String?
//    let isShowingScore: Bool
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//
//            Text(title)
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(.secondary)
//                .tracking(1.0)
//                .multilineTextAlignment(.center)
//            
//            if let score = score, isShowingScore {
//                ZStack {
//                    Circle()
//                        .fill(Color("ThemeGreen").opacity(0.1))
//                        .frame(width: 60, height: 60)
//                    
//                    Text("\(score)")
//                        .font(.system(size: 36, weight: .bold))
//                        .foregroundColor(Color("ThemeGreen"))
//                }
//                .animation(.bouncy(duration: 0.6), value: score)
//                
//            } else if let moodIcon = moodIcon {
//                Image(systemName: moodIcon)
//                    .font(.system(size: 24, weight: .medium))
//                    .foregroundColor(Color("ThemeGreen"))
//                    .frame(width: 44, height: 44)
//                    .background(Color("ThemeGreen").opacity(0.1))
//                    .clipShape(Circle())
//            } else {
//                Image(systemName: "arrow.right")
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//                    .frame(width: 44, height: 44)
//                    .background(Color("ThemeGreen"))
//                    .clipShape(Circle())
//            }
//            
//            Spacer()
//            
//            Text(subtitle)
//                .font(.system(size: 18, weight: .medium))
//                .foregroundColor(.primary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity)
//        .frame(height: 200)
//        .background(Color("LightBeige"))
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//}
//
//// MARK: - Convenience initializers
//extension ActionCard {
//    init(id: CardType, title: String, subtitle: String, action: @escaping () -> Void, flippedCard: Binding<CardType?>) {
//        self.id = id
//        self.title = title
//        self.subtitle = subtitle
//        self.score = nil
//        self.scoreSubtitle = nil
//        self.moodIcon = nil
//        self.action = action
//        self._flippedCard = flippedCard
//    }
//    
//    init(id: CardType, title: String, subtitle: String, moodIcon: String?, action: @escaping () -> Void, flippedCard: Binding<CardType?>) {
//        self.id = id
//        self.title = title
//        self.subtitle = subtitle
//        self.score = nil
//        self.scoreSubtitle = nil
//        self.moodIcon = moodIcon
//        self.action = action
//        self._flippedCard = flippedCard
//    }
//}
//
//// MARK: - Previews
//#Preview("ActionCard - Animation Demo") {
//    struct AnimationDemo: View {
//        @State private var score: Int? = nil
//        @State private var showButton = true
//        @State private var flippedCard: CardType? = nil   // 🔑 Add state for preview
//
//        var body: some View {
//            VStack(spacing: 20) {
//                Text("Flip Animation Demo")
//                    .font(.headline)
//                
//                ActionCard(
//                    id: .epds,
//                    title: "WEEKLY ASSESSMENT",
//                    subtitle: "Take quiz",
//                    score: score,
//                    scoreSubtitle: "Total Score",
//                    moodIcon: nil,
//                    action: { print("Card tapped") },
//                    flippedCard: $flippedCard // pass binding
//                )
//                
//                if showButton {
//                    Button("Simulate EPDS Completion") {
//                        withAnimation {
//                            score = 17
//                            flippedCard = .epds   // simulate flip
//                            showButton = false
//                        }
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//                
//                Button("Reset") {
//                    score = nil
//                    flippedCard = nil
//                    showButton = true
//                }
//                .padding()
//                .background(Color.gray)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//            }
//            .padding()
//            .background(Color("LightGrayBG"))
//        }
//    }
//    
//    return AnimationDemo()
//}
//
//#Preview("ActionCard - Mixed States") {
//    struct MixedStatesDemo: View {
//        @State private var flippedCard: CardType? = nil  // 🔑 shared state
//        
//        var body: some View {
//            VStack(spacing: 16) {
//                Text("Different Score Values")
//                    .font(.headline)
//                    .padding(.top)
//                
//                HStack(spacing: 16) {
//                    ActionCard(
//                        id: .epds,
//                        title: "WEEKLY ASSESSMENT",
//                        subtitle: "Take quiz",
//                        score: 5,
//                        scoreSubtitle: "Total Score",
//                        moodIcon: nil,
//                        action: { print("Low score tapped") },
//                        flippedCard: $flippedCard
//                    )
//                    
//                    ActionCard(
//                        id: .epds,
//                        title: "WEEKLY ASSESSMENT",
//                        subtitle: "Take quiz",
//                        score: 15,
//                        scoreSubtitle: "Total Score",
//                        moodIcon: nil,
//                        action: { print("High score tapped") },
//                        flippedCard: $flippedCard
//                    )
//                }
//                
//                HStack(spacing: 16) {
//                    ActionCard(
//                        id: .epds,
//                        title: "WEEKLY ASSESSMENT",
//                        subtitle: "Take quiz",
//                        score: nil,
//                        scoreSubtitle: "Total Score",
//                        moodIcon: nil,
//                        action: { print("No score tapped") },
//                        flippedCard: $flippedCard
//                    )
//                    
//                    ActionCard(
//                        id: .mood,
//                        title: "YOUR MOOD",
//                        subtitle: "Check in",
//                        moodIcon: "face.smiling",
//                        action: { print("Mood tapped") },
//                        flippedCard: $flippedCard
//                    )
//                }
//            }
//            .padding()
//            .background(Color("LightGrayBG"))
//        }
//    }
//    
//    return MixedStatesDemo()
//}
