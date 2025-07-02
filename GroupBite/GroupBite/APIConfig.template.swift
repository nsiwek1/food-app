import Foundation

struct APIConfig {
    // Replace this with your actual Google Places API key
    static let googlePlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE"
    
    // Google Places API endpoints
    static let googlePlacesBaseURL = "https://maps.googleapis.com/maps/api/place"
    static let nearbySearchEndpoint = "/nearbysearch/json"
    static let photoEndpoint = "/photo"
    
    // Default location (San Francisco) - you can change this to your preferred default
    static let defaultLatitude = 37.7749
    static let defaultLongitude = -122.4194
    
    // Check if API key is properly configured
    static func isAPIKeyConfigured() -> Bool {
        return !googlePlacesAPIKey.isEmpty && 
               googlePlacesAPIKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" &&
               googlePlacesAPIKey.count > 20 // Basic validation
    }
    
    // Generate photo URL for Google Places photos
    static func photoURL(photoReference: String) -> URL? {
        return URL(string: "\(googlePlacesBaseURL)\(photoEndpoint)?maxwidth=400&photoreference=\(photoReference)&key=\(googlePlacesAPIKey)")
    }
    
    // Test API key functionality
    static func testAPIKey() async -> Bool {
        guard isAPIKeyConfigured() else {
            print("❌ API key not configured")
            return false
        }
        
        // Make a simple test request to verify the API key works
        var components = URLComponents(string: googlePlacesBaseURL + nearbySearchEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "key", value: googlePlacesAPIKey),
            URLQueryItem(name: "location", value: "\(defaultLatitude),\(defaultLongitude)"),
            URLQueryItem(name: "radius", value: "1000"),
            URLQueryItem(name: "type", value: "restaurant")
        ]
        
        guard let url = components.url else {
            print("❌ Failed to build test URL")
            return false
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                return false
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                return false
            }
            
            // Try to decode the response to check if it's valid
            let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
            
            if placesResponse.status == "OK" || placesResponse.status == "ZERO_RESULTS" {
                print("✅ API key test successful")
                return true
            } else {
                print("❌ API Error: \(placesResponse.status)")
                return false
            }
            
        } catch {
            print("❌ API test failed: \(error)")
            return false
        }
    }
}

// MARK: - API Response Models (for testing)
struct PlacesResponse: Codable {
    let status: String
    let results: [Place]
}

struct Place: Codable {
    let place_id: String
    let name: String
    let vicinity: String
    let rating: Double?
    let user_ratings_total: Int?
    let price_level: Int?
    let types: [String]
    let photos: [PlacePhoto]?
    let opening_hours: OpeningHours?
    let geometry: Geometry
}

struct PlacePhoto: Codable {
    let photo_reference: String
    let height: Int
    let width: Int
}

struct OpeningHours: Codable {
    let open_now: Bool?
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
} 