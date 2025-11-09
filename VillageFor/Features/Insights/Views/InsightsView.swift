//
//  InsightsView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/2/25.
//


import SwiftUI

struct InsightsView: View {
    @State private var selectedRange: String = "1 month"
    private let ranges = ["1 month", "3 months", "6 months"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Header
                Text("Insights")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                // MARK: - Time Range Selector
                HStack(spacing: 10) {
                    ForEach(ranges, id: \.self) { range in
                        Button {
                            withAnimation(.spring()) {
                                selectedRange = range
                            }
                        } label: {
                            Text(range)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedRange == range ? .white : .primary)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedRange == range ? Color("ThemeGreen") : Color(.systemGray6))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // MARK: - Mood Grid Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your mood")
                            .font(.headline)
                        Spacer()
                        Text("18 check-ins")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    MoodGridView()

                    Button {
                        // Later: Navigate to mood reports
                    } label: {
                        Text("View mood reports")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("ThemeGreen"))
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                // MARK: - Key Insight Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key insight")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Your mood has been trending in a positive direction this month.")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    ProgressView(value: 0.77)
                        .tint(Color("ThemePurple"))
                        .scaleEffect(x: 1, y: 1.2, anchor: .center)

                    HStack {
                        Label("Negative", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("23%")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Label("Positive", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundColor(Color("ThemePurple"))
                        Spacer()
                        Text("77%")
                            .font(.caption)
                            .foregroundColor(Color("ThemePurple"))
                    }
                }
                .padding()
                .background(Color("ThemePurple").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color("LightGrayBG").ignoresSafeArea())
    }
}

// MARK: - Mood Grid Mock
struct MoodGridView: View {
    private let colors: [Color] = [
        .yellow, .green, .pink, .gray.opacity(0.2), .pink,
        .gray.opacity(0.1), .blue.opacity(0.3), .blue.opacity(0.3), .green.opacity(0.4),
        .yellow.opacity(0.3), .gray.opacity(0.2), .green.opacity(0.4),
        .yellow, .green.opacity(0.5), .blue.opacity(0.3), .purple.opacity(0.3)
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            ForEach(0..<30) { index in
                RoundedRectangle(cornerRadius: 6)
                    .fill(index < colors.count ? colors[index] : Color.gray.opacity(0.1))
                    .frame(height: 30)
            }
        }
    }
}

#Preview {
    InsightsView()
        .environment(\.colorScheme, .light)
}
