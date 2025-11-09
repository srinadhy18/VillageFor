//
//  EPDSOptionButton.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/9/25.
//

import SwiftUI

struct EPDSOptionButton: View {
    let text: String
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color("EPDSGreen"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color("EPDSGreen") : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        EPDSOptionButton(text: "Selected Answer", isSelected: true, action: {})
        EPDSOptionButton(text: "Unselected Answer", isSelected: false, action: {})
    }
    .padding()
    .background(Color(UIColor.systemGray6))
}
