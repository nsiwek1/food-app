import Foundation
import FirebaseFirestore

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let description: String?
    let createdBy: String // User ID
    let members: [String] // User IDs
    let inviteCode: String
    let isActive: Bool
    let createdAt: Date
    let currentSessionId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdBy
        case members
        case inviteCode
        case isActive
        case createdAt
        case currentSessionId
    }
    
    init(name: String, description: String?, createdBy: String) {
        self.name = name
        self.description = description
        self.createdBy = createdBy
        self.members = [createdBy]
        self.inviteCode = UUID().uuidString.prefix(8).uppercased()
        self.isActive = true
        self.createdAt = Date()
        self.currentSessionId = nil
    }
} 