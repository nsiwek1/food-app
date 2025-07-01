import Foundation
import FirebaseFirestore

struct GroupSession: Identifiable, Codable {
    @DocumentID var id: String?
    let groupId: String
    let createdBy: String
    let createdAt: Date
    let isActive: Bool
    let restaurants: [Restaurant]
    let filters: SessionFilters
    var memberSwipes: [String: [String: Swipe.SwipeAction]] // userId -> restaurantId -> action
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId
        case createdBy
        case createdAt
        case isActive
        case restaurants
        case filters
        case memberSwipes
    }
    
    init(groupId: String, createdBy: String, restaurants: [Restaurant], filters: SessionFilters) {
        self.groupId = groupId
        self.createdBy = createdBy
        self.createdAt = Date()
        self.isActive = true
        self.restaurants = restaurants
        self.filters = filters
        self.memberSwipes = [:]
    }
}

struct SessionFilters: Codable {
    let radius: Double
    let priceLevel: Int
    let types: [String]
    let searchQuery: String
    
    init(radius: Double = 5000, priceLevel: Int = 0, types: [String] = ["restaurant"], searchQuery: String = "") {
        self.radius = radius
        self.priceLevel = priceLevel
        self.types = types
        self.searchQuery = searchQuery
    }
} 