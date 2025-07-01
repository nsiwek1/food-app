import Foundation
import FirebaseFirestore

struct Swipe: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let groupId: String
    let sessionId: String?
    let restaurantId: String
    let action: SwipeAction
    let timestamp: Date
    
    enum SwipeAction: String, Codable, CaseIterable {
        case like = "like"
        case dislike = "dislike"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case groupId
        case sessionId
        case restaurantId
        case action
        case timestamp
    }
    
    init(userId: String, groupId: String, sessionId: String? = nil, restaurantId: String, action: SwipeAction) {
        self.userId = userId
        self.groupId = groupId
        self.sessionId = sessionId
        self.restaurantId = restaurantId
        self.action = action
        self.timestamp = Date()
    }
    
    // Backward compatibility initializer
    init(userId: String, groupId: String, sessionId: String, restaurantId: String, isLiked: Bool) {
        self.userId = userId
        self.groupId = groupId
        self.sessionId = sessionId
        self.restaurantId = restaurantId
        self.action = isLiked ? .like : .dislike
        self.timestamp = Date()
    }
} 