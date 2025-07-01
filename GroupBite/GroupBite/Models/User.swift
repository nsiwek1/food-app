import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let username: String
    let displayName: String
    let profileImageURL: String?
    let createdAt: Date
    let groups: [String] // Group IDs
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case displayName
        case profileImageURL
        case createdAt
        case groups
    }
    
    init(email: String, username: String, displayName: String, profileImageURL: String? = nil) {
        self.email = email
        self.username = username
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.createdAt = Date()
        self.groups = []
    }
} 