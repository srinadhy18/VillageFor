//
//  ArticleRepository.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/1/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class ArticleRepository: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = ArticleRepository()
    
    // MARK: - Published Properties
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil
    
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // Prevent anyone else from creating a new instance
    private init() {}
    
    // MARK: - Public API
    
    /// Begins listening for article updates in Firestore.
    func startListening() {
        // Avoid multiple listeners
        guard listener == nil else {
            print("ArticleRepository: Already listening to Firestore.")
            return
        }
        
        isLoading = true
        print("ArticleRepository: Starting listener...")
        
        listener = db.collection("articles")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching articles: \(error.localizedDescription)"
                    print("Firestore error:", error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.articles = []
                    print("No articles found in Firestore.")
                    return
                }
                
                self.articles = documents.compactMap { doc in
                    try? doc.data(as: Article.self)
                }
                
                print("ArticleRepository: Loaded \(self.articles.count) articles.")
            }
    }
    
    /// Stops the Firestore listener (if needed for memory or testing).
    func stopListening() {
        listener?.remove()
        listener = nil
        print("ArticleRepository: Stopped Firestore listener.")
    }
    
    /// Optionally refresh manually once (e.g., for pull-to-refresh)
    func refresh() async {
        do {
            let snapshot = try await db.collection("articles")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            self.articles = snapshot.documents.compactMap { doc in
                try? doc.data(as: Article.self)
            }
            print("ArticleRepository: Manual refresh fetched \(self.articles.count) articles.")
        } catch {
            self.errorMessage = "Failed to refresh: \(error.localizedDescription)"
        }
    }
}
