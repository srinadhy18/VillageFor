//
//  MainTabView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/17/25.
//

import SwiftUI

struct MainTabView: View {
    // we will have user object here so that we can pass the user details if if we want them in specific tabs.
    
    // Access the sessionManager from the environment to pass it down or use it here.
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedTab: TabBarModel = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Area
            // The switch statement determines which view to show based on the selected tab.
            Group {
                
                if let user = sessionManager.currentUser {
                    switch selectedTab {
                    case .home:
                        HomeView(user: user)
                    case .tools:
                        //Passing below views temporarily. change it after creating in future development.
                        HomeView(user: user)
                    case .learn:
                        LearnView()
                            .environmentObject(sessionManager)
                    case .insights:
                        InsightsView()
                    case .me:
                        HomeView(user: user)
                    }
                }else {
                    // Optional fallback if no user session found
                    VStack {
                        ProgressView("Loading user...")
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if !sessionManager.isTabBarHidden {
                TabBarView(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: .resetToHomeTab)) { _ in
            print("MainTabView: Received resetToHomeTab, switching to home tab")
            selectedTab = .home
            print("MainTabView: Set selectedTab to .home")        }
    }
}
