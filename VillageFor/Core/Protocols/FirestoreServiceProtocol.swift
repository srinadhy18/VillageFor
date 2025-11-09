//
//  FirestoreServiceProtocol.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/8/25.
//

import Foundation

// This protocol defines the "contract" for what a Firestore service must do.
protocol FirestoreServiceProtocol {
    func saveUserProfile(user: User) async throws
    func updateUserAge(uid: String, age: Int) async throws
    func saveUserConsent(agreedToHealthData: Bool, agreedToTerms: Bool) async throws
    func updateUserPreferences(uid: String, preferences: NotificationPreferences) async throws
    func fetchUserProfile(uid: String) async throws -> User?

    // We would add other functions here etc.
    func saveDailyCheckin(uid: String, checkin: DailyCheckin) async throws 
    func fetchLatestCheckin(uid: String) async throws -> DailyCheckin?
    func updateUserDataConsent(uid: String, dataConsent: DataConsent) async throws
    
    func updateUserPregnancyPostpartumData(
         uid: String,
         pregnancyStatus: String?,
         isFirstPregnancy: Bool?,
         isPostpartum: Bool?,
         postpartumWeeks: Int?,
         isFirstPostpartumExperience: Bool?,
         mentalHealthProfessionalType: String?
     ) async throws
    
    func fetchLatestEPDSAssessment(uid: String) async throws -> EPDSAssessment?
    func saveEPDSAssessment(uid: String, assessment: EPDSAssessment) async throws
    
    func fetchArticles() async throws -> [Article]
    
    func fetchAllCheckins(uid: String) async throws -> [DailyCheckin]
}
