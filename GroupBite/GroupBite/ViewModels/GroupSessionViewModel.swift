import Foundation
import FirebaseFirestore
import CoreLocation

@MainActor
class GroupSessionViewModel: ObservableObject {
    @Published var currentSession: GroupSession?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let restaurantViewModel = RestaurantViewModel()
    
    func createSession(
        for groupId: String,
        filters: SessionFilters,
        location: CLLocation? = nil
    ) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get 10 restaurants based on filters
            let restaurants = await getRestaurantsForSession(filters: filters, location: location)
            
            guard !restaurants.isEmpty else {
                errorMessage = "No restaurants found with the selected filters. Try adjusting your search criteria."
                isLoading = false
                return
            }
            
            // Create session with the restaurant list
            let session = GroupSession(
                groupId: groupId,
                createdBy: getCurrentUserId(),
                restaurants: restaurants,
                filters: filters
            )
            
            // Save to Firestore
            let docRef = try await db.collection("groupSessions").addDocument(from: session)
            
            // Update current session with the document ID
            var updatedSession = session
            updatedSession.id = docRef.documentID
            currentSession = updatedSession
            
            isLoading = false
            
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func loadSession(for groupId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("groupSessions")
                .whereField("groupId", isEqualTo: groupId)
                .whereField("isActive", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                currentSession = try document.data(as: GroupSession.self)
            }
            
            isLoading = false
            
        } catch {
            errorMessage = "Failed to load session: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func recordSwipe(restaurantId: String, action: Swipe.SwipeAction) async {
        guard let session = currentSession else { return }
        
        do {
            let userId = getCurrentUserId()
            
            // Update the session's memberSwipes
            var updatedSession = session
            if updatedSession.memberSwipes[userId] == nil {
                updatedSession.memberSwipes[userId] = [:]
            }
            updatedSession.memberSwipes[userId]?[restaurantId] = action
            
            // Save to Firestore
            if let sessionId = session.id {
                try await db.collection("groupSessions").document(sessionId).setData(from: updatedSession)
                currentSession = updatedSession
            }
            
        } catch {
            errorMessage = "Failed to record swipe: \(error.localizedDescription)"
        }
    }
    
    func getMatches() -> [Restaurant] {
        guard let session = currentSession else { return [] }
        
        let memberIds = Set(session.memberSwipes.keys)
        guard memberIds.count > 1 else { return [] } // Need at least 2 members
        
        var matches: [Restaurant] = []
        
        for restaurant in session.restaurants {
            let restaurantId = restaurant.id
            var allLiked = true
            
            for memberId in memberIds {
                if session.memberSwipes[memberId]?[restaurantId] != .like {
                    allLiked = false
                    break
                }
            }
            
            if allLiked {
                matches.append(restaurant)
            }
        }
        
        return matches
    }
    
    private func getRestaurantsForSession(filters: SessionFilters, location: CLLocation?) async -> [Restaurant] {
        // Use the restaurant view model to get restaurants
        await restaurantViewModel.searchRestaurants(
            query: filters.searchQuery,
            location: location,
            radius: filters.radius,
            priceLevel: filters.priceLevel,
            types: filters.types
        )
        
        // Return the first 10 restaurants
        return Array(restaurantViewModel.restaurants.prefix(10))
    }
    
    private func getCurrentUserId() -> String {
        // This should get the current user ID from your auth system
        // For now, return a placeholder
        return "current_user_id"
    }
} 