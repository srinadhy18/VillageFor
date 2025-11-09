//
//  InsightsViewModel.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 11/2/25.
//

import SwiftUI

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var checkins: [DailyCheckin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService()
    
    func loadCheckins(for uid: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await firestoreService.fetchAllCheckins(uid: uid)
            self.checkins = data
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
