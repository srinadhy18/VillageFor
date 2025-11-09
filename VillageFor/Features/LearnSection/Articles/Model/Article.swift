//
//  Article.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 7/2/25.
//


//import Foundation
//
//struct Article: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let imageURL: String
//}
//

import Foundation
import FirebaseFirestore

struct Article: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var subtitle: String
    var content: String
    var imageURL: String
    var category: String           // "Mental health", "Physical health", etc.
    var createdAt: Date
}
