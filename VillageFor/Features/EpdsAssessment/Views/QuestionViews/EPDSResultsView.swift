//
//  EPDSResultsView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 9/14/25.
//

import SwiftUI
import Charts

struct EPDSResultsView: View {
    let assessment: EPDSAssessment
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingSendToProvider = false
    @Environment(\.dismiss) private var dismiss
    
    // Sample data for the chart - replace with actual historical data
    private let historicalScores = [
        ChartDataPoint(date: "Jul 1", score: 17),
        ChartDataPoint(date: "Jul 8", score: 15),
        ChartDataPoint(date: "Jul 15", score: 14),
        ChartDataPoint(date: "Jul 22", score: 18),
        ChartDataPoint(date: "Jul 31", score: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 50) {
                
                // Header with download button
                HStack {
                    Text("Your score")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle download action
                    }) {
                        Image(systemName: "arrow.down.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Score Card
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("EPDSGreen"))
                    
                    VStack(spacing: 0) {
                        // Top section with pattern image spanning full width
                        Image("EpdsResultPatternLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 60)
                            .clipped()
                            .opacity(0.15)
                            .allowsHitTesting(false)
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .frame(height: 80) // Space for the pattern area
                        
                        // Label below pattern area
                        HStack {
                            Text("EPDS-US TOTAL SCORE")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: {
                                // Show info about scoring
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        Spacer()
                        
                        // Score at bottom left - use actual assessment score
                        HStack {
                            Text("\(assessment.totalScore)")
                                .font(.system(size: 72, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                }
                .frame(height: 160)
                
                // Interpretation Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("What your score means")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your answers show that you might be feeling overwhelmed or low. This is a good moment to take a step back and think about your emotional health.")
                            .foregroundColor(.primary)
                        
                        Text("While this tool doesn't provide a diagnosis, it's a helpful way to recognize when it might be time to connect with someone, like a healthcare provider or counselor. You don't have to face this alone there are people who want to support you and help you feel your best.")
                            .foregroundColor(.primary)
                    }
                }
                .padding(20)
                .background(Color("LightBeige"))
                .cornerRadius(16)
                
                // Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("YOUR SCORES IN THE PAST MONTH")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    // Chart
                    Chart {
                        ForEach(historicalScores, id: \.date) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Score", dataPoint.score)
                            )
                            .foregroundStyle(Color("EPDSGreen"))
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Date", dataPoint.date),
                                yStart: .value("Min Score", 0),
                                yEnd: .value("Score", dataPoint.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("EPDSGreen").opacity(0.3), Color("EPDSGreen").opacity(0.01)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Score", dataPoint.score)
                            )
                            .foregroundStyle(Color("EPDSGreen"))
                            .symbolSize(60)
                        }
                    }
                    .frame(height: 200)
                    .chartYScale(domain: 0...30)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                                .foregroundStyle(.gray.opacity(0.3))
                            AxisValueLabel()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Send to Provider Button
                VStack(spacing: 16) {
                    Button("Send to provider") {
                        showingSendToProvider = true
                    }
                    .font(.headline)
                    .foregroundColor(Color("EPDSGreen"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    
                    // Continue Button - Navigate back to home and refresh data
                    Button("Continue") {
                        handleContinue()
                    }
                    .buttonStyle(.primary)
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .background(Color("LightGrayBG"))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            CustomBackButtonToolbar()
            ToolbarItem(placement: .navigationBarTrailing) {
                DismissButton()
            }
        }
        .sheet(isPresented: $showingSendToProvider) {
            // Send to Provider sheet view
            SendToProviderView()
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleContinue() {
        // Show the tab bar again
        sessionManager.isTabBarHidden = false
        
        // Post a notification to refresh home data BEFORE dismissing
        NotificationCenter.default.post(name: .epdsAssessmentCompleted, object: nil)
        sessionManager.navigateToHome()
    }
}

// Helper struct for chart data
struct ChartDataPoint {
    let date: String
    let score: Int
}

struct SendToProviderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Send to Provider")
                    .font(.title)
                    .padding()
                
                Text("This feature would allow you to share your results with your healthcare provider.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Send Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        // Create assessment with sample data
        let sampleAssessment = EPDSAssessment(timestamp: .init(date: Date()))
        // Note: You'll need to set the totalScore through your assessment's initialization
        // or create a method to set it, since we can't modify it here
        
        EPDSResultsView(assessment: sampleAssessment)
            .environmentObject(SessionManager())
    }
}
