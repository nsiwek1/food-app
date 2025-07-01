import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    let phoneNumber: String?
    let website: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let priceLevel: Int? // 0-4, where 0 is free and 4 is very expensive
    let types: [String] // Cuisine types
    let photos: [String]? // Photo references
    let photoReference: String? // Single photo reference for display
    let openingHours: [String]? // Days of the week
    let isOpenNow: Bool?
    let location: CLLocationCoordinate2D
    let placeId: String // Google Places ID
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case phoneNumber
        case website
        case rating
        case userRatingsTotal
        case priceLevel
        case types
        case photos
        case photoReference
        case openingHours
        case isOpenNow
        case latitude
        case longitude
        case placeId
    }
    
    init(placeId: String, name: String, address: String, location: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.placeId = placeId
        self.name = name
        self.address = address
        self.location = location
        self.phoneNumber = nil
        self.website = nil
        self.rating = nil
        self.userRatingsTotal = nil
        self.priceLevel = nil
        self.types = []
        self.photos = nil
        self.photoReference = nil
        self.openingHours = nil
        self.isOpenNow = nil
    }
    
    init(id: String, name: String, address: String, rating: Double?, priceLevel: Int?, types: [String], placeId: String, photoReference: String?) {
        self.id = id
        self.name = name
        self.address = address
        self.placeId = placeId
        self.rating = rating
        self.priceLevel = priceLevel
        self.types = types
        self.photoReference = photoReference
        self.location = CLLocationCoordinate2D(latitude: 0, longitude: 0) // Default location
        self.phoneNumber = nil
        self.website = nil
        self.userRatingsTotal = nil
        self.photos = nil
        self.openingHours = nil
        self.isOpenNow = nil
    }
    
    // Comprehensive initializer for all properties
    init(
        id: String,
        name: String,
        address: String,
        phoneNumber: String?,
        website: String?,
        rating: Double?,
        userRatingsTotal: Int?,
        priceLevel: Int?,
        types: [String],
        photos: [String]?,
        photoReference: String?,
        openingHours: [String]?,
        isOpenNow: Bool?,
        location: CLLocationCoordinate2D,
        placeId: String
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
        self.rating = rating
        self.userRatingsTotal = userRatingsTotal
        self.priceLevel = priceLevel
        self.types = types
        self.photos = photos
        self.photoReference = photoReference
        self.openingHours = openingHours
        self.isOpenNow = isOpenNow
        self.location = location
        self.placeId = placeId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        placeId = try container.decode(String.self, forKey: .placeId)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal)
        priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel)
        types = try container.decode([String].self, forKey: .types)
        photos = try container.decodeIfPresent([String].self, forKey: .photos)
        photoReference = try container.decodeIfPresent(String.self, forKey: .photoReference)
        openingHours = try container.decodeIfPresent([String].self, forKey: .openingHours)
        isOpenNow = try container.decodeIfPresent(Bool.self, forKey: .isOpenNow)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(placeId, forKey: .placeId)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(userRatingsTotal, forKey: .userRatingsTotal)
        try container.encodeIfPresent(priceLevel, forKey: .priceLevel)
        try container.encode(types, forKey: .types)
        try container.encodeIfPresent(photos, forKey: .photos)
        try container.encodeIfPresent(photoReference, forKey: .photoReference)
        try container.encodeIfPresent(openingHours, forKey: .openingHours)
        try container.encodeIfPresent(isOpenNow, forKey: .isOpenNow)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
    }
} 