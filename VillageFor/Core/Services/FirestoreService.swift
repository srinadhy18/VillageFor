//
//  FirestoreService.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 6/30/25.
//

import Foundation
import FirebaseFirestore

class FirestoreService: FirestoreServiceProtocol {

    // You can keep this method if it serves a purpose, but it's not used by DataConsentViewModel
    func saveUserConsent(agreedToHealthData: Bool, agreedToTerms: Bool) async throws {
        print("saveUserConsent called - need to get an update from christy regarding the placement of this screen")
        // This method's logic might be superseded by updateUserDataConsent.
        // Consider removing it if it's no longer necessary.
    }


    // Get a reference to the 'users' collection in Firestore
    private let usersCollection = Firestore.firestore().collection("users")

    private func userDocument(uid: String) -> DocumentReference {
        return usersCollection.document(uid)
    }

    // Saves the user's profile data to Firestore
    func saveUserProfile(user: User) async throws {
        // We use the user's unique ID (from Firebase Auth) as the document ID
        // This links the auth user to their database record.
        // The `Codable` conformance on our User model lets us do this easily.
        try await userDocument(uid: user.id).setData(from: user, merge: true)
    }

    /// Updates the age for a specific user in Firestore.
    func updateUserAge(uid: String, age: Int) async throws {
        // Use updateData to change only specific fields of a document
        // without overwriting the whole thing.
        try await usersCollection.document(uid).updateData(["age": age])
    }

    func updateUserPreferences(uid: String, preferences: NotificationPreferences) async throws {
        // We need to convert the struct to a dictionary to save it
        let data: [String: Any] = [ // Explicitly define type as [String: Any]
            "moodCheckins": preferences.moodCheckins,
            "epdsAssessments": preferences.epdsAssessments,
            "dailyAffirmations": preferences.dailyAffirmations
        ]
        try await userDocument(uid: uid).updateData(["notificationPreferences": data])
    }

    // ✨ New implementation for Data Consent ✨
    func updateUserDataConsent(uid: String, dataConsent: DataConsent) async throws {
        var consentData: [String: Any] = [:]

        // Handle the optional `terms` consent item
        if let terms = dataConsent.terms {
            consentData["terms"] = [
                "isAgreed": terms.isAgreed,
                "timestamp": terms.timestamp,
                "version": terms.version
            ]
        }

        // Handle the non-optional `healthData` consent item
        consentData["healthData"] = [
            "isAgreed": dataConsent.healthData.isAgreed,
            "timestamp": dataConsent.healthData.timestamp,
            "version": dataConsent.healthData.version
        ]

        try await userDocument(uid: uid).updateData(["dataConsent": consentData])
        print("FirestoreService: Updated dataConsent for user \(uid) in Firestore.")
    }


    func fetchUserProfile(uid: String) async throws -> User? {
        let snapshot = try await usersCollection.document(uid).getDocument()
        // If the document doesn't exist or data is nil, snapshot.data(as: User.self)
        // will throw an error or return nil, which is handled by 'try?'.
        // It's better to explicitly check for existence for clarity.
        guard snapshot.exists else {
            print("FirestoreService: User profile document for \(uid) does not exist.")
            return nil
        }
        return try snapshot.data(as: User.self)
    }

    //MARK: Daily mood checkin.

    func saveDailyCheckin(uid: String, checkin: DailyCheckin) async throws {
        // This creates a new document in a "dailyCheckins" subcollection for the user.
        // Using `addDocument(from:)` leverages Codable.
        try userDocument(uid: uid).collection("dailyCheckins").addDocument(from: checkin)
    }

    func fetchLatestCheckin(uid: String) async throws -> DailyCheckin? {
        let snapshot = try await userDocument(uid: uid)
            .collection("dailyCheckins")
            // Order the results by timestamp, with the newest first
            .order(by: "timestamp", descending: true)
            // We only need the single most recent document
            .limit(to: 1)
            .getDocuments()

        // Safely decode and return the first document found, or nil if none exist.
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DailyCheckin.self)
        }.first
    }
    
    func updateUserPregnancyPostpartumData(
            uid: String,
            pregnancyStatus: String?,
            isFirstPregnancy: Bool?,
            isPostpartum: Bool?,
            postpartumWeeks: Int?,
            isFirstPostpartumExperience: Bool?,
            mentalHealthProfessionalType: String?
        ) async throws {
            var data: [String: Any] = [:]

            // Only add non-nil values to the update dictionary
            if let status = pregnancyStatus { data["pregnancyStatus"] = status }
            if let firstPreg = isFirstPregnancy { data["isFirstPregnancy"] = firstPreg }
            if let postpartum = isPostpartum { data["isPostpartum"] = postpartum }
            if let weeks = postpartumWeeks { data["postpartumWeeks"] = weeks }
            if let firstPostExp = isFirstPostpartumExperience { data["isFirstPostpartumExperience"] = firstPostExp }
            if let mentalHealth = mentalHealthProfessionalType { data["mentalHealthProfessionalType"] = mentalHealth } // Correct key for Firestore

            if data.isEmpty {
                print("FirestoreService: No data to update for pregnancy/postpartum/mental health. Skipping update.")
                return
            }

            do {
                try await usersCollection.document(uid).updateData(data)
                print("FirestoreService: Batch updated pregnancy/postpartum/mental health data for user \(uid).")
            } catch {
                print("FirestoreService: Error batch updating pregnancy/postpartum/mental health data: \(error.localizedDescription)")
                throw error
            }
        }
    
    enum FirestoreError: Error, LocalizedError {
          case invalidUserID
          case documentNotFound

          var errorDescription: String? {
              switch self {
              case .invalidUserID: return "The user ID is invalid or missing."
              case .documentNotFound: return "The requested document could not be found."
              }
          }
      }
    
    func fetchLatestEPDSAssessment(uid: String) async throws -> EPDSAssessment? {
        let assessmentsRef = userDocument(uid: uid).collection("epdsAssessments")
        
        // Order by timestamp in descending order and get the most recent one
        let query = assessmentsRef.order(by: "timestamp", descending: true).limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        // Decode the first document found, if any
        return try snapshot.documents.first?.data(as: EPDSAssessment.self)
    }
    
    /// Saves a completed EPDS assessment to the user's profile.
       func saveEPDSAssessment(uid: String, assessment: EPDSAssessment) async throws {
           // Saves the assessment to a new "epdsAssessments" subcollection.
           let documentRef = userDocument(uid: uid).collection("epdsAssessments").document()
           try await documentRef.setData(from: assessment)
           print("EPDS assessment saved successfully with ID: \(documentRef.documentID)")
       }
    
    
    /// Articles related services
        func fetchArticles() async throws -> [Article] {
            let snapshot = try await Firestore.firestore()
                .collection("articles")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            // Decode Firestore documents into Article model
            return snapshot.documents.compactMap { document in
                try? document.data(as: Article.self)
            }
        }
    
    ///Insights section
    func fetchAllCheckins(uid: String) async throws -> [DailyCheckin] {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("dailyCheckins")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: DailyCheckin.self) }
    }
    
}
