import Foundation
import CoreLocation
import FirebaseFirestore

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var isMockMode = false // Set to false to use real API
    
    func searchRestaurants(
        query: String = "",
        location: CLLocation? = nil,
        radius: Double = 5000,
        priceLevel: Int = 0, // 0 means any price level
        types: [String] = ["restaurant"]
    ) async {
        print("🚀 SEARCH RESTAURANTS CALLED!")
        print("   Query: '\(query)'")
        print("   Location: \(location?.description ?? "nil")")
        print("   Radius: \(radius)")
        print("   Price Level: \(priceLevel)")
        print("   Types: \(types)")
        
        isLoading = true
        errorMessage = nil
        
        print("🔍 Restaurant Search Debug:")
        print("   isMockMode: \(isMockMode)")
        print("   isAPIKeyConfigured: \(APIConfig.isAPIKeyConfigured())")
        
        // Temporarily force real API usage for testing
        print("✅ Using real Google Places API (forced)")
        
        // Comment out mock data fallback for now
        /*
        if isMockMode || !APIConfig.isAPIKeyConfigured() {
            print("⚠️  Using mock data - API key not configured or mock mode enabled")
            // Fall back to mock data if no API key or mock mode is enabled
            restaurants = generateMockRestaurants(
                query: query,
                priceLevel: priceLevel,
                types: types,
                count: 15
            )
            isLoading = false
            return
        }
        */
        
        do {
            print("🌐 Making API call to Google Places...")
            let restaurants = try await searchPlacesAPI(
                query: query,
                location: location,
                radius: radius,
                priceLevel: priceLevel,
                types: types
            )
            
            print("✅ API call successful! Found \(restaurants.count) restaurants")
            self.restaurants = restaurants
            isLoading = false
            
        } catch {
            print("❌ API call failed with error: \(error)")
            errorMessage = "Failed to search restaurants: \(error.localizedDescription)"
            isLoading = false
            
            print("⚠️  Falling back to mock data due to API error")
            // Fall back to mock data on error
            restaurants = generateMockRestaurants(
                query: query,
                priceLevel: priceLevel,
                types: types,
                count: 15
            )
        }
    }
    
    private func searchPlacesAPI(
        query: String,
        location: CLLocation?,
        radius: Double,
        priceLevel: Int,
        types: [String]
    ) async throws -> [Restaurant] {
        print("🔧 Building API URL...")
        var components = URLComponents(string: APIConfig.googlePlacesBaseURL + APIConfig.nearbySearchEndpoint)!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "key", value: APIConfig.googlePlacesAPIKey),
            URLQueryItem(name: "radius", value: String(Int(radius))),
            URLQueryItem(name: "type", value: "restaurant")
        ]
        
        print("🔑 Using API Key: \(APIConfig.googlePlacesAPIKey.prefix(10))...")
        
        // Add location if available
        if let location = location {
            queryItems.append(URLQueryItem(name: "location", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"))
        } else {
            // Default to San Francisco if no location
            queryItems.append(URLQueryItem(name: "location", value: "\(APIConfig.defaultLatitude),\(APIConfig.defaultLongitude)"))
        }
        
        // Add price level filter
        if priceLevel > 0 {
            queryItems.append(URLQueryItem(name: "maxprice", value: String(priceLevel)))
        }
        
        // Add keyword search
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "keyword", value: query))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("❌ Failed to build URL")
            throw URLError(.badURL)
        }
        
        print("🌐 Making request to: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw URLError(.badServerResponse)
        }
        
        print("📡 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        print("📄 Response data size: \(data.count) bytes")
        
        let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
        
        print("📊 API Response Status: \(placesResponse.status)")
        print("📊 Found \(placesResponse.results.count) places")
        
        if placesResponse.status != "OK" && placesResponse.status != "ZERO_RESULTS" {
            print("❌ API Error Status: \(placesResponse.status)")
            throw PlacesAPIError.serverError(placesResponse.status)
        }
        
        // Convert places to restaurants
        var restaurants: [Restaurant] = []
        
        for place in placesResponse.results {
            let restaurant = Restaurant(
                id: place.place_id,
                name: place.name,
                address: place.vicinity,
                phoneNumber: nil, // Would need additional API call
                website: nil, // Would need additional API call
                rating: place.rating,
                userRatingsTotal: place.user_ratings_total,
                priceLevel: place.price_level,
                types: place.types,
                photos: place.photos?.map { $0.photo_reference },
                photoReference: place.photos?.first?.photo_reference,
                openingHours: nil, // Would need additional API call
                isOpenNow: place.opening_hours?.open_now,
                location: CLLocationCoordinate2D(
                    latitude: place.geometry.location.lat,
                    longitude: place.geometry.location.lng
                ),
                placeId: place.place_id
            )
            restaurants.append(restaurant)
        }
        
        return restaurants
    }
    
    // Keep the mock data generation for fallback
    private func generateMockRestaurants(
        query: String,
        priceLevel: Int,
        types: [String],
        count: Int
    ) -> [Restaurant] {
        let mockRestaurants = [
            Restaurant(
                id: "1",
                name: "Pizza Palace",
                address: "123 Main St, Downtown",
                phoneNumber: "+1-555-0123",
                website: "https://pizzapalace.com",
                rating: 4.5,
                userRatingsTotal: 1250,
                priceLevel: 2,
                types: ["pizza", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                placeId: "place_1"
            ),
            Restaurant(
                id: "2",
                name: "Sushi Master",
                address: "456 Oak Ave, Midtown",
                phoneNumber: "+1-555-0456",
                website: "https://sushimaster.com",
                rating: 4.8,
                userRatingsTotal: 890,
                priceLevel: 3,
                types: ["sushi", "japanese", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                placeId: "place_2"
            ),
            Restaurant(
                id: "3",
                name: "Taco Fiesta",
                address: "789 Pine St, Uptown",
                phoneNumber: "+1-555-0789",
                website: "https://tacofiesta.com",
                rating: 4.2,
                userRatingsTotal: 567,
                priceLevel: 1,
                types: ["mexican", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                placeId: "place_3"
            ),
            Restaurant(
                id: "4",
                name: "Burger Joint",
                address: "321 Elm St, Downtown",
                phoneNumber: "+1-555-0321",
                website: "https://burgerjoint.com",
                rating: 4.0,
                userRatingsTotal: 1200,
                priceLevel: 2,
                types: ["american", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                placeId: "place_4"
            ),
            Restaurant(
                id: "5",
                name: "Pasta House",
                address: "654 Maple Dr, Midtown",
                phoneNumber: "+1-555-0654",
                website: "https://pastahouse.com",
                rating: 4.6,
                userRatingsTotal: 750,
                priceLevel: 3,
                types: ["italian", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                placeId: "place_5"
            ),
            Restaurant(
                id: "6",
                name: "Curry Corner",
                address: "987 Cedar Ln, Uptown",
                phoneNumber: "+1-555-0987",
                website: "https://currycorner.com",
                rating: 4.4,
                userRatingsTotal: 680,
                priceLevel: 2,
                types: ["indian", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                placeId: "place_6"
            ),
            Restaurant(
                id: "7",
                name: "Pho Express",
                address: "147 Birch Ave, Downtown",
                phoneNumber: "+1-555-0147",
                website: "https://phoexpress.com",
                rating: 4.3,
                userRatingsTotal: 420,
                priceLevel: 1,
                types: ["vietnamese", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                placeId: "place_7"
            ),
            Restaurant(
                id: "8",
                name: "Steak House",
                address: "258 Spruce St, Midtown",
                phoneNumber: "+1-555-0258",
                website: "https://steakhouse.com",
                rating: 4.7,
                userRatingsTotal: 950,
                priceLevel: 4,
                types: ["american", "steakhouse", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                placeId: "place_8"
            ),
            Restaurant(
                id: "9",
                name: "Ramen Shop",
                address: "369 Willow Way, Uptown",
                phoneNumber: "+1-555-0369",
                website: "https://ramenshop.com",
                rating: 4.5,
                userRatingsTotal: 580,
                priceLevel: 2,
                types: ["japanese", "ramen", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                placeId: "place_9"
            ),
            Restaurant(
                id: "10",
                name: "Greek Taverna",
                address: "741 Poplar Blvd, Downtown",
                phoneNumber: "+1-555-0741",
                website: "https://greektaverna.com",
                rating: 4.1,
                userRatingsTotal: 320,
                priceLevel: 2,
                types: ["greek", "mediterranean", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                placeId: "place_10"
            ),
            Restaurant(
                id: "11",
                name: "Thai Spice",
                address: "852 Magnolia Dr, Midtown",
                phoneNumber: "+1-555-0852",
                website: "https://thaispice.com",
                rating: 4.4,
                userRatingsTotal: 450,
                priceLevel: 2,
                types: ["thai", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                placeId: "place_11"
            ),
            Restaurant(
                id: "12",
                name: "BBQ Pit",
                address: "963 Hickory Ln, Uptown",
                phoneNumber: "+1-555-0963",
                website: "https://bbqpit.com",
                rating: 4.6,
                userRatingsTotal: 780,
                priceLevel: 3,
                types: ["american", "bbq", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                placeId: "place_12"
            ),
            Restaurant(
                id: "13",
                name: "Seafood Market",
                address: "159 Cypress St, Downtown",
                phoneNumber: "+1-555-0159",
                website: "https://seafoodmarket.com",
                rating: 4.3,
                userRatingsTotal: 620,
                priceLevel: 3,
                types: ["seafood", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                placeId: "place_13"
            ),
            Restaurant(
                id: "14",
                name: "Vegan Garden",
                address: "357 Sycamore Ave, Midtown",
                phoneNumber: "+1-555-0357",
                website: "https://vegangarden.com",
                rating: 4.2,
                userRatingsTotal: 380,
                priceLevel: 2,
                types: ["vegan", "vegetarian", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                placeId: "place_14"
            ),
            Restaurant(
                id: "15",
                name: "Dessert Cafe",
                address: "486 Cherry Way, Uptown",
                phoneNumber: "+1-555-0486",
                website: "https://dessertcafe.com",
                rating: 4.5,
                userRatingsTotal: 290,
                priceLevel: 2,
                types: ["cafe", "dessert", "restaurant", "food"],
                photos: nil,
                photoReference: nil,
                openingHours: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                isOpenNow: true,
                location: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                placeId: "place_15"
            )
        ]
        
        // Filter based on search criteria
        var filtered = mockRestaurants
        
        // Filter by search query
        if !query.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(query) ||
                restaurant.types.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }
        
        // Filter by price level (0 means any price)
        if priceLevel > 0 {
            filtered = filtered.filter { restaurant in
                restaurant.priceLevel == priceLevel
            }
        }
        
        // Filter by types
        if !types.isEmpty && !types.contains("restaurant") {
            filtered = filtered.filter { restaurant in
                !Set(restaurant.types).isDisjoint(with: Set(types))
            }
        }
        
        // If no results after filtering, return all restaurants
        if filtered.isEmpty {
            filtered = mockRestaurants
        }
        
        // Return up to the requested count
        return Array(filtered.prefix(count))
    }
    
    func likeRestaurant(_ restaurant: Restaurant, for groupId: String) async {
        do {
            let swipe = Swipe(
                userId: getCurrentUserId(),
                groupId: groupId,
                restaurantId: restaurant.id,
                action: .like
            )
            
            try await db.collection("swipes").document(swipe.id ?? UUID().uuidString).setData(from: swipe)
        } catch {
            errorMessage = "Failed to like restaurant: \(error.localizedDescription)"
        }
    }
    
    func dislikeRestaurant(_ restaurant: Restaurant, for groupId: String) async {
        do {
            let swipe = Swipe(
                userId: getCurrentUserId(),
                groupId: groupId,
                restaurantId: restaurant.id,
                action: .dislike
            )
            
            try await db.collection("swipes").document(swipe.id ?? UUID().uuidString).setData(from: swipe)
        } catch {
            errorMessage = "Failed to dislike restaurant: \(error.localizedDescription)"
        }
    }
    
    func getMatches(for groupId: String) async -> [Restaurant] {
        do {
            let swipesSnapshot = try await db.collection("swipes")
                .whereField("groupId", isEqualTo: groupId)
                .getDocuments()
            
            let swipes = try swipesSnapshot.documents.compactMap { document in
                try document.data(as: Swipe.self)
            }
            
            // Group swipes by restaurant ID
            var restaurantSwipes: [String: [Swipe]] = [:]
            for swipe in swipes {
                if restaurantSwipes[swipe.restaurantId] == nil {
                    restaurantSwipes[swipe.restaurantId] = []
                }
                restaurantSwipes[swipe.restaurantId]?.append(swipe)
            }
            
            // Find restaurants where all group members liked
            var matchedRestaurants: [Restaurant] = []
            
            for (restaurantId, restaurantSwipes) in restaurantSwipes {
                let likes = restaurantSwipes.filter { $0.action == .like }
                let dislikes = restaurantSwipes.filter { $0.action == .dislike }
                
                // If everyone liked and no one disliked, it's a match
                if !likes.isEmpty && dislikes.isEmpty {
                    // In a real app, you'd fetch the restaurant details from your database
                    // For now, we'll create a placeholder
                    let matchedRestaurant = Restaurant(
                        id: restaurantId,
                        name: "Matched Restaurant",
                        address: "Address",
                        rating: 4.5,
                        priceLevel: 2,
                        types: ["restaurant"],
                        placeId: restaurantId,
                        photoReference: nil
                    )
                    matchedRestaurants.append(matchedRestaurant)
                }
            }
            
            return matchedRestaurants
        } catch {
            errorMessage = "Failed to get matches: \(error.localizedDescription)"
            return []
        }
    }
    
    private func getCurrentUserId() -> String {
        // This should get the current user ID from your auth system
        // For now, return a placeholder
        return "current_user_id"
    }
}

// MARK: - API Response Models

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

enum PlacesAPIError: Error {
    case serverError(String)
    case invalidResponse
} 