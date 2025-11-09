VillageFor: A Mental Health Companion for Mothers
VillageFor is a native iOS application designed as a supportive companion for mothers, focusing on mental and emotional well-being during pregnancy and postpartum. The app provides tools for self-reflection, mood tracking, and clinical assessments in a beautifully designed, user-friendly interface.

Core Features
Secure Onboarding & Profile Creation: A comprehensive 10+ screen onboarding flow that securely registers users with Firebase Authentication and captures over 30 essential data points to a Cloud Firestore backend.

Daily Mood Check-in: A guided 4-step daily check-in process that allows users to log their mood and energy levels, select emotions, journal their thoughts, and identify contributing factors.

Clinical EPDS Assessment: A full 10-question implementation of the Edinburgh Postnatal Depression Scale (EPDS) with a final checklist, score calculation, and a results screen with historical data visualization.

Dynamic Home Screen: A central dashboard that provides daily affirmations and dynamically updates to reflect the user's latest mood check-in and weekly EPDS score.

Persistent User Settings: Smart use of @AppStorage and UserDefaults to remember user preferences, such as skipping introductory screens on subsequent uses.

Screenshots (under development - development hours estimated till Nov 22nd)

Technical Stack & Architecture
This project was built from the ground up using a modern, scalable, and testable architecture.

UI Framework: SwiftUI (100% Declarative UI)

Backend: Firebase (Serverless)

Authentication: For secure user sign-up, login, and session management.

Cloud Firestore: A NoSQL database for storing all user profile data, mood check-ins, and assessment results.

Architecture: MVVM (Model-View-ViewModel)

Ensures a clean separation of concerns, keeping the UI logic separate from the business logic.

Each feature is organized into its own dedicated module for scalability.

Concurrency: Swift Concurrency (async/await)

Used for all network operations with Firebase to ensure the UI remains fast, responsive, and never blocks the main thread.

State Management:

A centralized SessionManager injected via @EnvironmentObject manages global state like the current user and authentication status.

@StateObject and @ObservedObject are used for managing the state of individual views.

Testing: XCTest

A suite of unit tests for key ViewModels, validating business logic like the EPDS scoring algorithm and weekly check-in date calculations.

Utilizes protocols and dependency injection to create mock services, isolating tests from live network dependencies.

Project Structure
The project is organized into a clean, feature-based folder structure to promote scalability and maintainability.


