//
//  EmotionDisplayCard.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/21/25.
//

import SwiftUI


struct EmotionDisplayCard: View {
    let emotion: String
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(emotion.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(0.9)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(24)
        .frame(height: 140)
        .background(backgroundColor)
        .cornerRadius(24)
        .shadow(color: backgroundColor.opacity(0.3),
                radius: 8, x: 0, y: 4)
    }
}
