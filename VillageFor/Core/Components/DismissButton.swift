//
//  DismissButton.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/21/25.
//


import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) var dismiss // Access the dismiss action from the environment

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.black)
                .padding(8)
//                .background(Color.white) // Added a background color for the circle fill
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
        }
    }
}
