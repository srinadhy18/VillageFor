//
//  LearnViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/01/25.
//

import Foundation
import Combine

@MainActor
final class LearnViewModel: ObservableObject {
    @Published var allArticles: [Article] = []
    @Published var filteredArticles: [Article] = []
    @Published var selectedCategory: String = "Mental health"
    @Published var searchQuery: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        // Subscribe to shared repository updates
        ArticleRepository.shared.$articles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.allArticles = $0
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        ArticleRepository.shared.$isLoading
            .assign(to: &$isLoading)
        
        ArticleRepository.shared.$errorMessage
            .assign(to: &$errorMessage)
        
        // Start listening only once (no multiple Firestore calls)
        ArticleRepository.shared.startListening()
    }
    
    // MARK: - Filtering
    func applyFilters() {
        let search = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let category = selectedCategory.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        filteredArticles = allArticles.filter { article in
            article.category.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == category &&
            (search.isEmpty || article.title.lowercased().contains(search) || article.subtitle.lowercased().contains(search))
        }
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
        applyFilters()
    }
    
    func refresh() async {
        await ArticleRepository.shared.refresh()
    }
}



// MARK: - Mock Initializer for Previews
extension LearnViewModel {
    convenience init(mockArticles: [Article]) {
        self.init()
        self.allArticles = mockArticles
        self.filteredArticles = mockArticles
        self.isLoading = false
        self.errorMessage = nil
    }
}

final class MockFirestoreService: FirestoreServiceProtocol {

    // Stubs to satisfy protocol
    func saveUserProfile(user: User) async throws {}
    func updateUserAge(uid: String, age: Int) async throws {}
    func saveUserConsent(agreedToHealthData: Bool, agreedToTerms: Bool) async throws {}
    func updateUserPreferences(uid: String, preferences: NotificationPreferences) async throws {}
    func fetchUserProfile(uid: String) async throws -> User? { nil }
    func updateUserDataConsent(uid: String, dataConsent: DataConsent) async throws {}
    func saveDailyCheckin(uid: String, checkin: DailyCheckin) async throws {}
    func fetchLatestCheckin(uid: String) async throws -> DailyCheckin? { nil }
    func updateUserPregnancyPostpartumData(
        uid: String,
        pregnancyStatus: String?,
        isFirstPregnancy: Bool?,
        isPostpartum: Bool?,
        postpartumWeeks: Int?,
        isFirstPostpartumExperience: Bool?,
        mentalHealthProfessionalType: String?
    ) async throws {}
    func fetchLatestEPDSAssessment(uid: String) async throws -> EPDSAssessment? { nil }
    func saveEPDSAssessment(uid: String, assessment: EPDSAssessment) async throws {}
    func fetchArticles() async throws -> [Article] { [] }
    func fetchAllCheckins(uid: String) async throws -> [DailyCheckin] { [] }
    
}
