//
//  HomeViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/2/25.
//

import Foundation
import SwiftUICore
import FirebaseAuth

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var userName: String
    @Published var dailyAffirmation: Affirmation
    @Published var supportArticles: [Article]
    
    @Published var shouldNavigateToMoodCheck = false
    
    @Published var shouldNavigateToEPDSIntroduction = false
    @Published var shouldNavigateDirectlyToEPDS = false
    
    @Published var shouldNavigateToLearn = false

    
    // MARK: - Services
    private let authService: AuthenticationServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    //mood check-in
    @Published var latestCheckin: DailyCheckin?
    
    // This will hold the full assessment object from Firestore
    @Published private var latestAssessment: EPDSAssessment?
    var lastMoodCheckinDate: Date? {
        latestCheckin?.timestamp.dateValue()
    }
    
    /// This computed property contains the logic to decide whether to show the score.
    var epdsScoreToShow: Int? {
        // 1. Make sure we have an assessment
        guard let assessment = latestAssessment else {
            return nil // No assessment, so show "Take quiz"
        }
        
        // 2. Convert the Firestore Timestamp to a Date
        let assessmentDate = assessment.timestamp.dateValue()
        
        // 3. Check if more than 7 days have passed
        if let daysSince = Calendar.current.dateComponents([.day], from: assessmentDate, to: Date()).day, daysSince >= 7 {
            return nil // It's been a week or more, so show "Take quiz"
        }
        
        // 4. If it's been less than a week, return the score
        return assessment.totalScore
    }
    
    var moodDisplayText: String? {
        guard hasCheckedInToday, let checkin = latestCheckin else {
            return nil // No check-in today → show "Check in"
        }
        return checkin.moodName ?? "Checked in"
    }
    
    /// Computed property for mood icon based on the latest check-in
    var moodIcon: String? {
        guard hasCheckedInToday,
              let checkin = latestCheckin,
              let moodName = checkin.moodName else {
            return nil // No check-in or not today
        }
        
        // Map mood names to SF Symbols
        switch moodName.lowercased() {
        case "happy", "joyful", "elated":
            return "sun.max.fill"
        case "sad", "down", "depressed":
            return "cloud.rain.fill"
        case "anxious", "worried", "nervous":
            return "heart.fill"
        case "angry", "frustrated", "irritated":
            return "flame.fill"
        case "tired", "exhausted", "sleepy":
            return "moon.zzz.fill"
        case "calm", "peaceful", "relaxed":
            return "leaf.fill"
        case "excited", "energetic", "enthusiastic":
            return "bolt.fill"
        case "overwhelmed", "stressed":
            return "cloud.bolt.fill"
        case "grateful", "thankful":
            return "heart.circle.fill"
        case "confused", "uncertain":
            return "questionmark.circle.fill"
        case "astonished", "surprised":
            return "startled"
        default:
            return "startled" // Default mood icon
        }
    }
    
    init(user: User, authService: AuthenticationServiceProtocol = AuthenticationService(),
         firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.userName = user.firstName ?? "User"
        self.authService = authService
        self.firestoreService = firestoreService
        
        // Initializing with sample data
        self.dailyAffirmation = Affirmation(
            text: "I release guilt about not being with my child every moment. I provide for and nurture my child in my own unique way."
        )
        //Later we can call live articles using API here.
        self.supportArticles = [
            Article(
                id: UUID().uuidString,
                title: "What to Expect During Morning Sickness",
                subtitle: "Understanding symptoms and ways to manage early pregnancy nausea.",
                content: """
                Morning sickness is common during the first trimester, caused by hormonal changes and heightened sensitivity to smells. 
                Try eating small, frequent meals, staying hydrated, and getting plenty of rest.
                Avoid triggers such as strong odors or an empty stomach. 
                Remember, it’s temporary—and if symptoms become severe, talk to your healthcare provider.
                """,
                imageURL: "https://example.com/morning-sickness.jpg",
                category: "Physical health",
                createdAt: Date()
            ),
            Article(
                id: UUID().uuidString,
                title: "Preparing for Your Baby’s Arrival",
                subtitle: "Essential tips for getting ready for your new bundle of joy.",
                content: """
                From setting up the nursery to packing your hospital bag, preparing early can reduce stress. 
                Make a checklist of essentials—diapers, onesies, wipes, and a car seat. 
                Take time for self-care and consider joining prenatal classes or online support groups.
                Small steps now can make your first weeks smoother.
                """,
                imageURL: "https://example.com/baby-prep.jpg",
                category: "Community",
                createdAt: Date()
            )
        ]
        
        // Set up notification observer for EPDS completion
        setupNotificationObservers()
        
        Task {
            await fetchLatestCheckin()
            await fetchLatestEPDSAssessment()
        }
    }
    
    deinit {
        // Clean up notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Setup
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .epdsAssessmentCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.refreshAfterEPDSCompletion()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToHome,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("HomeViewModel: Received navigateToHome notification")
            Task { @MainActor in
                self?.resetAllNavigationStates()
                print("HomeViewModel: Reset navigation states")
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .moodCheckinCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.refreshAfterMoodCheckin()
            }
        }
    }
    
    func refreshAfterMoodCheckin() async {
        await fetchLatestCheckin()
        
        if let affirmationText = latestCheckin?.checkInAffirmation {
            // Use the saved affirmation
            dailyAffirmation = Affirmation(text: affirmationText)
        } else if let mood = latestCheckin?.moodName {
            // Fallback: regenerate if no saved affirmation
            dailyAffirmation = affirmationForMood(mood)
        }
    }
    
    var hasCheckedInToday: Bool {
        guard let checkin = latestCheckin else { return false }
        let checkinDate = checkin.timestamp.dateValue()
        return Calendar.current.isDateInToday(checkinDate)
    }
    
    var shouldResetMood: Bool {
        !hasCheckedInToday
    }
    
    private func resetAllNavigationStates() {
        print("HomeViewModel: Before reset - EPDS: \(shouldNavigateToEPDSIntroduction), Direct: \(shouldNavigateDirectlyToEPDS)")
        shouldNavigateToEPDSIntroduction = false
        shouldNavigateDirectlyToEPDS = false
        shouldNavigateToMoodCheck = false
        print("HomeViewModel: After reset - EPDS: \(shouldNavigateToEPDSIntroduction), Direct: \(shouldNavigateDirectlyToEPDS)")
    }
    
    
    /// Fetches the most recent DailyCheckin document from Firestore for the current user.
    func fetchLatestCheckin() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            self.latestCheckin = try await firestoreService.fetchLatestCheckin(uid: uid)
            if let affirmationText = latestCheckin?.checkInAffirmation {
                self.dailyAffirmation = Affirmation(text: affirmationText)
            }
            print("Successfully fetched latest check-in.")
        } catch {
            print("Error fetching latest check-in: \(error.localizedDescription)")
        }
    }
    
    func fetchLatestEPDSAssessment() async {
        guard let userid = Auth.auth().currentUser?.uid else { return }
        
        do {
            self.latestAssessment = try await firestoreService.fetchLatestEPDSAssessment(uid: userid)
            print("Fetched latest EPDS assessment. Score: \(latestAssessment?.totalScore ?? -1)")
        } catch {
            print("Error fetching latest EPDS assessment: \(error.localizedDescription)")
        }
    }
    
    /// Call this method after EPDS assessment completion to refresh the data
    func refreshAfterEPDSCompletion() async {
        await fetchLatestEPDSAssessment()
    }
    
    /// Refresh all data - useful for pull-to-refresh or onAppear
    func refreshAllData() async {
        await fetchLatestCheckin()
        await fetchLatestEPDSAssessment()
        // reset to default if mood expired
        if shouldResetMood {
            latestCheckin = nil
            dailyAffirmation = Affirmation(
                text: "I release guilt about not being with my child every moment. I provide for and nurture my child in my own unique way."
            )
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func navigateToMoodCheck() {
        shouldNavigateToMoodCheck = true
        print("Navigate to mood check")
    }
    
    func navigateToEPDSAssessment() {
        if UserDefaults.standard.shouldShowEPDSIntroduction {
            shouldNavigateToEPDSIntroduction = true
        } else {
            // If the user chose not to see the intro, go straight to the questions.
            shouldNavigateDirectlyToEPDS = true
        }
        print("Navigate to EPDS assessment")
    }
    
    private func affirmationForMood(_ mood: String) -> Affirmation {
        switch mood.lowercased() {
        case "happy", "joyful", "elated":
            return Affirmation(text: "I embrace the joy I feel today and let it guide my actions.")
        case "sad", "down", "depressed":
            return Affirmation(text: "It’s okay to feel this way. I am gentle with myself.")
        case "anxious", "worried":
            return Affirmation(text: "I release tension with every breath. I am safe in this moment.")
        case "angry", "frustrated":
            return Affirmation(text: "I acknowledge my feelings and choose peace moving forward.")
        case "tired", "exhausted":
            return Affirmation(text: "Rest is a gift I deserve. I allow myself to recharge.")
        case "calm", "peaceful":
            return Affirmation(text: "I am present, balanced, and grounded.")
        case "grateful", "thankful":
            return Affirmation(text: "I appreciate the beauty and blessings in my life.")
        default:
            return Affirmation(text: "I am strong, resilient, and capable of handling what comes my way.")
        }
    }
    
}
