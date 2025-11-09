//
//  HomeView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/2/25.
//


import SwiftUI
import FirebaseCore


struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject var sessionManager: SessionManager
        
    init(user: User) {
        // we are creating the ViewModel and injecting the user data.
        _viewModel = StateObject(wrappedValue: HomeViewModel(user: user))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HeaderView(userName: viewModel.userName, signOutAction:{ viewModel.signOut() })
                    
                    // Daily Affirmation Card
                    AffirmationCard(affirmation: viewModel.dailyAffirmation)
                    
                    // Action Cards
                    HStack(spacing: 16) {
                        MoodActionCard(
                            title: "YOUR MOOD",
                            subtitle: "Check in",
                            emotion: viewModel.shouldResetMood ? nil : viewModel.latestCheckin?.moodName,
                            iconName: viewModel.shouldResetMood ? nil : viewModel.moodIcon,
                            lastLoggedDate: viewModel.lastMoodCheckinDate,
                            action: {
                                sessionManager.isTabBarHidden = true
                                viewModel.navigateToMoodCheck()
                            }
                        )
                        
                        EPDSActionCard(
                            title: "WEEKLY ASSESSMENT",
                            subtitle: "Take quiz",
                            score: viewModel.epdsScoreToShow,
                            scoreSubtitle: "Total Score",
                            action: {
                                sessionManager.isTabBarHidden = true
                                viewModel.navigateToEPDSAssessment()
                            }
                        )
                    }
                    
                    // Support Section
                    SupportSection(articles: viewModel.supportArticles)
                }
                //pull-to-refresh functionality to check latest checkin.
                .refreshable {
                    await viewModel.fetchLatestCheckin()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40) // Extra padding for tab bar
            }
            .padding(.top, 15)
            .background(Color("LightGrayBG"))
            .ignoresSafeArea(.container, edges: .bottom) // Only ignore safe area at bottom
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                sessionManager.isTabBarHidden = false
            }
            .navigationDestination(
                isPresented: $viewModel.shouldNavigateToMoodCheck,
                destination: {
                    // Creating a NEW DailyCheckin object when starting the flow.
                    let newCheckin = DailyCheckin(timestamp: .init(date: Date()))
                    MoodCheckinView(dailyCheckin: newCheckin)
                }
            )
            
            .navigationDestination(isPresented: $viewModel.shouldNavigateToEPDSIntroduction) {
                // Create a new assessment object when the flow starts
                let newAssessment = EPDSAssessment(timestamp: Timestamp())
                EPDSIntroductionView(assessment: newAssessment)
                    .environmentObject(sessionManager)
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateDirectlyToEPDS) {
                // Also create a new assessment object when skipping the intro
                let newAssessment = EPDSAssessment(timestamp: Timestamp())
                EPDSQuestion1View(assessment: newAssessment)
                    .environmentObject(sessionManager)
            }
            
        }
    }
}

#Preview {
    let sampleUser = User(id: "123", email: "preview@test.com", firstName: "Caroline", lastName: "Brown")
    
    NavigationStack {
        HomeView(user: sampleUser).environmentObject(SessionManager())
    }
}



