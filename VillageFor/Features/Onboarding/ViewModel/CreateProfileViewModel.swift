//
//  CreateProfileViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//
//
//  CreateProfileViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI // Make sure SwiftUI is imported for @Binding

@MainActor
class CreateProfileViewModel: ObservableObject {

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    /// we won't be saving password in User struct, this is just for UI purpose.
    @Published var password = ""

    // Field-specific error messages
    @Published var firstNameError: String?
    @Published var lastNameError: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var phoneNumberError: String?

    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var profileSaveSuccess = false

    private let firestoreService = FirestoreService()

    //Learnings: binding allows the ViewModel to receive the hasCompletedOnboarding flag from view
    @Binding var hasCompletedOnboarding: Bool

    init(hasCompletedOnboarding: Binding<Bool>) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
    }

    // `createUserAndSaveProfile` needs to accept the `SessionManager`
    // instance to update `currentUser`.
    func createUserAndSaveProfile(sessionManager: SessionManager) async {
        // Always validate all fields before submission
        validateAllFields()

        // Check if there are any validation errors
        if hasValidationErrors() {
            return // Don't proceed if there are validation errors
        }

        clearFieldErrors()
        isLoading = true
        errorMessage = nil

        do {
            // Step 1: Create Firebase Auth user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created with UID: \(authResult.user.uid)")

            // Step 2: Create user profile object
            let userProfile = User(
                id: authResult.user.uid,
                email: self.email,
                firstName: self.firstName,
                lastName: self.lastName,
                phoneNumber: self.phoneNumber,
                age: nil, // Age and notification preferences are set in AgePickerView
                notificationPreferences: nil
            )

            // Step 3: Save to Firestore
            try await firestoreService.saveUserProfile(user: userProfile)

            // ✨ Key Change 3: Update the SessionManager's currentUser ✨
            // This is vital. After successfully creating and saving the user's
            // initial profile, we must update the shared SessionManager
            // so that higher-level views (like VillageForApp) know the user is logged in
            // and have access to their basic profile data.
            sessionManager.currentUser = userProfile
            print("SessionManager currentUser updated after profile creation.")

            profileSaveSuccess = true
            print("Profile saved successfully! Navigating to next onboarding step.")

        } catch let error as NSError {
            handleFirebaseError(error)
        }

        isLoading = false
    }

    // The `saveProfile()` function seems redundant in this onboarding flow
    // if `createUserAndSaveProfile()` is handling initial creation.
    // If `saveProfile()` is intended for *existing* users updating their profiles
    // *after* onboarding, it should remain separate. For the onboarding flow,
    // we'll primarily use `createUserAndSaveProfile()`.
    // If you confirm `saveProfile()` is for a different part of the app,
    // you can keep it as is, but it won't be part of the onboarding binding chain.
    /*
    func saveProfile() async {
        validateAllFields()

        if hasValidationErrors() {
            return
        }

        clearFieldErrors()
        isLoading = true
        errorMessage = nil

        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No authenticated user found. Please sign in first."
            isLoading = false
            return
        }

        let userProfile = User(
            id: currentUser.uid,
            email: self.email,
            firstName: self.firstName,
            lastName: self.lastName,
            phoneNumber: self.phoneNumber,
            age: nil, // This would need to be passed if updating existing user
            notificationPreferences: nil // This would need to be passed if updating existing user
        )

        do {
            try await firestoreService.saveUserProfile(user: userProfile) // This will overwrite or merge, depending on FirestoreService impl
            profileSaveSuccess = true
            print("Profile saved successfully!")
        } catch let error as NSError {
            handleFirebaseError(error)
        }

        isLoading = false
    }
    */

    private func clearFieldErrors() {
        firstNameError = nil
        lastNameError = nil
        emailError = nil
        passwordError = nil
        phoneNumberError = nil
    }

    // Method to clear a specific field error (useful when user starts typing again)
    func clearFieldError(for field: String) {
        switch field {
        case "firstName":
            firstNameError = nil
        case "lastName":
            lastNameError = nil
        case "email":
            emailError = nil
        case "password":
            passwordError = nil
        case "phoneNumber":
            phoneNumberError = nil
        default:
            break
        }
    }

    private func handleFirebaseError(_ error: NSError) {
        print("❌ Firebase Error: \(error.localizedDescription)")
        print("Error Code: \(error.code)")
        print("Error Domain: \(error.domain)")

        if error.domain == AuthErrorDomain {
            switch AuthErrorCode(rawValue: error.code) {
            case .emailAlreadyInUse:
                emailError = "This email is already registered."
            case .invalidEmail:
                emailError = "Please enter a valid email address."
            case .weakPassword:
                passwordError = "Password should be at least 6 characters."
            case .networkError:
                errorMessage = "Network error. Please check your connection."
            case .userNotFound:
                emailError = "User not found."
            case .wrongPassword:
                passwordError = "Incorrect password."
            default:
                errorMessage = "Authentication error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Could not save profile: \(error.localizedDescription)"
        }
    }

    // Optional: Add validation methods (called on demand, not real-time)
    func validateEmail() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            emailError = "Email is required."
        } else if !isValidEmail(trimmedEmail) {
            emailError = "Please enter a valid email address."
        } else {
            emailError = nil
        }
    }

    func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 6 {
            passwordError = "Password should be at least 6 characters."
        } else if !hasCapitalLetter(password) {
            passwordError = "Password must contain at least one capital letter."
        } else if !hasNumber(password) {
            passwordError = "Password must contain at least one number."
        } else if !hasSpecialCharacter(password) {
            passwordError = "Password must contain at least one special character."
        } else if containsFirstOrLastName(password) {
            passwordError = "Password should not contain your first name or last name."
        } else {
            passwordError = nil
        }
    }

    func validateFirstName() {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedFirstName.isEmpty {
            firstNameError = "First name is required."
        } else if containsNumbers(trimmedFirstName) {
            firstNameError = "First name should not contain numbers."
        } else if trimmedFirstName.count < 2 {
            firstNameError = "First name should be at least 2 characters."
        } else {
            firstNameError = nil
        }
    }

    func validateLastName() {
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLastName.isEmpty {
            lastNameError = "Last name is required."
        } else if containsNumbers(trimmedLastName) {
            lastNameError = "Last name should not contain numbers."
        } else if trimmedLastName.count < 2 {
            lastNameError = "Last name should be at least 2 characters."
        } else {
            lastNameError = nil
        }
    }

    func validatePhoneNumber() {
        let trimmedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        // Phone number is optional, so only validate if not empty
        if !trimmedPhoneNumber.isEmpty {
            if containsLetters(trimmedPhoneNumber) {
                phoneNumberError = "Phone number should only contain numbers and formatting characters."
            } else if trimmedPhoneNumber.count < 10 {
                phoneNumberError = "Phone number should be at least 10 digits."
            } else {
                phoneNumberError = nil
            }
        } else {
            phoneNumberError = nil
        }
    }

    // Validate all fields (useful for form submission)
    func validateAllFields() {
        validateFirstName()
        validateLastName()
        validateEmail()
        validatePassword()
        validatePhoneNumber()
    }

    // Check if there are any validation errors
    private func hasValidationErrors() -> Bool {
        return firstNameError != nil ||
               lastNameError != nil ||
               emailError != nil ||
               passwordError != nil ||
               phoneNumberError != nil
    }

    // Enhanced continue button disabled logic
    var isContinueButtonDisabled: Bool {
        return firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               password.isEmpty ||
               isLoading
    }
    


    // MARK: - Validation Helper Methods

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func hasCapitalLetter(_ text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }

    private func hasNumber(_ text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

    private func hasSpecialCharacter(_ text: String) -> Bool {
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        return text.rangeOfCharacter(from: specialCharacters) != nil
    }

    private func containsFirstOrLastName(_ password: String) -> Bool {
        let lowercasePassword = password.lowercased()
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check if password contains first name (if it's not empty and at least 3 characters)
        if !trimmedFirstName.isEmpty && trimmedFirstName.count >= 3 {
            if lowercasePassword.contains(trimmedFirstName) {
                return true
            }
        }
        // Check if password contains last name (if it's not empty and at least 3 characters)
        if !trimmedLastName.isEmpty && trimmedLastName.count >= 3 {
            if lowercasePassword.contains(trimmedLastName) {
                return true
            }
        }
        return false
    }

    private func containsNumbers(_ text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }

    private func containsLetters(_ text: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789+()-. ")
        return text.rangeOfCharacter(from: allowedCharacters.inverted) != nil
    }
}
