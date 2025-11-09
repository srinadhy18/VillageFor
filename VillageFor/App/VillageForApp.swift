import SwiftUI
import FirebaseCore // Assuming Firebase setup

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct VillageForApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var sessionManager = SessionManager()
    
    //flag for our onboarding completion
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    // Debugging prints to see the app's state
                    let _ = print("App State - hasCompletedOnboarding: \(hasCompletedOnboarding), currentUser: \(sessionManager.currentUser?.id ?? "nil")")
                    
#if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-debugBypassLogin") {
                        // This block is for development/testing convenience
                        MainTabView()
                            .onAppear {
                                sessionManager.currentUser = MockData.sampleUser // Set a mock user
                                hasCompletedOnboarding = true // Mark onboarding complete for bypass
                            }
                            .environmentObject(sessionManager)
                    } else {
                        // Production/Regular Debug Logic
                        Group {
                            // Decide whether to show MainTabView or WelcomeView
                            if hasCompletedOnboarding && sessionManager.currentUser != nil {
                                let _ = print("Showing MainTabView (Onboarding complete & user logged in)")
                                MainTabView()
                                    .environmentObject(sessionManager)
                            } else {
                                let _ = print("Showing WelcomeView (Onboarding not complete or user not logged in)")
                                // Pass the @AppStorage binding to WelcomeView
                                WelcomeView(hasCompletedOnboarding: $hasCompletedOnboarding)
                                    .environmentObject(sessionManager)
                            }
                        }
                    }
#else
                    // Production Code - no debug bypass
                    if hasCompletedOnboarding && sessionManager.currentUser != nil {
                        MainTabView().environmentObject(sessionManager)
                    } else {
                        WelcomeView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(sessionManager)
                    }
#endif
                }
                
                if isShowingSplash {
                    SplashScreenView() // Your splash screen
                        .transition(.opacity)
                }
            }
            .font(.epilogue(size: 14))
            .onAppear {
                // Dismiss splash screen after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            }
            // Add an observer to react if sessionManager.currentUser changes.
            // This handles cases where a returning user's `currentUser` is fetched
            // after app launch, and we need to check if their profile is complete.
            .onChange(of: sessionManager.currentUser) { newUser in
                if let user = newUser {
                    // Use the logic in SessionManager to determine if the user has completed onboarding
                    hasCompletedOnboarding = sessionManager.hasCompletedOnboarding(user: user)
                    print("currentUser changed. hasCompletedOnboarding (AppStorage) updated to: \(hasCompletedOnboarding)")
                } else {
                    // If user logs out, reset the persistent flag
                    hasCompletedOnboarding = false
                    print("currentUser logged out. hasCompletedOnboarding (AppStorage) reset to false.")
                }
            }
        }
    }
}

#if DEBUG
struct MockData {
    // Ensure this mock user has all fields needed for `hasCompletedOnboarding` logic
    static let sampleUser = User(
        id: "debug_user_123",
        email: "srinadh@debug.com",
        firstName: "Sri",
        lastName: "Debug",
        age: 26,
        notificationPreferences: NotificationPreferences(moodCheckins: true, epdsAssessments: true, dailyAffirmations: true),
        
        pregnancyStatus: "No", // Example value
        isFirstPregnancy: false, // Example value
        isPostpartum: true, // Example value
        postpartumWeeks: 12, // Example value
        isFirstPostpartumExperience: false, // Example value
        mentalHealthProfessionalType: "Yes, a therapist" // Example value
    )
}
#endif



extension Font {
    
    /// Creates a custom Epilogue font with the specified size and weight.
    /// - Parameters:
    ///   - size: The point size of the font.
    ///   - weight: The desired font weight.
    /// - Returns: A custom Font instance.
    static func epilogue(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // This maps the standard SwiftUI font weights to your custom font files.
        // IMPORTANT: The string names ("Epilogue-Regular", "Epilogue-Bold") must
        // match the font's PostScript name exactly. You can find this by
        // opening the font file in the "Font Book" application on your Mac.
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Epilogue-Bold"
        case .medium:
            fontName = "Epilogue-Medium"
        case .semibold:
            fontName = "Epilogue-SemiBold"
        // Add other weights like .light, .extrabold etc. if you have them.
        default:
            fontName = "Epilogue-Regular"
        }
        
        return .custom(fontName, size: size)
    }
}

