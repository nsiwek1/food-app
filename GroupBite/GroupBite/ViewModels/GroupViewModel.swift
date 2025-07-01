import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class GroupViewModel: ObservableObject {
    @Published var userGroups: [Group] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isMockMode = false
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // Reference to AuthViewModel to check bypass state
    private var authViewModel: AuthViewModel?
    
    func setAuthViewModel(_ authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        print("GroupViewModel: AuthViewModel reference set")
    }
    
    init() {
        print("GroupViewModel: Initializing...")
        testFirestoreConnection()
    }
    
    private func testFirestoreConnection() {
        print("GroupViewModel: Testing Firestore connection...")
        
        Task {
            do {
                let testDoc = try await db.collection("test").document("connection").getDocument()
                print("GroupViewModel: Firestore connection successful")
                print("GroupViewModel: Using real Firebase - mock mode disabled")
            } catch {
                print("GroupViewModel: Firestore connection failed: \(error.localizedDescription)")
                print("GroupViewModel: Error details: \(error)")
                
                // Check if it's a LevelDB lock error
                if error.localizedDescription.contains("LevelDB") || 
                   error.localizedDescription.contains("lock") ||
                   error.localizedDescription.contains("Resource temporarily unavailable") {
                    print("GroupViewModel: Detected LevelDB lock error - switching to mock mode...")
                    isMockMode = true
                    addMockGroups()
                } else {
                    print("GroupViewModel: Other Firebase error - trying to continue with real Firebase...")
                    // Don't switch to mock mode for other errors, try to continue
                }
            }
        }
    }
    
    private func addMockGroups() {
        print("GroupViewModel: Adding mock groups...")
        let mockGroup1 = Group(name: "Lunch Buddies", description: "Finding great lunch spots together", createdBy: "mockuser1")
        let mockGroup2 = Group(name: "Dinner Club", description: "Exploring new restaurants", createdBy: "mockuser2")
        
        userGroups = [mockGroup1, mockGroup2]
        print("GroupViewModel: Added \(userGroups.count) mock groups")
    }
    
    func createGroup(name: String, description: String?) async {
        // Check if we're in bypass mode or mock mode
        let isBypassMode = authViewModel?.isAuthenticated == true && Auth.auth().currentUser == nil
        let shouldUseMock = isMockMode || isBypassMode
        
        print("GroupViewModel: Creating group - Mock mode: \(isMockMode), Bypass mode: \(isBypassMode), Should use mock: \(shouldUseMock)")
        
        if shouldUseMock {
            await createMockGroup(name: name, description: description)
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let group = Group(name: name, description: description, createdBy: currentUserId)
            let docRef = try await db.collection("groups").addDocument(from: group)
            
            // Update user's groups array
            try await db.collection("users").document(currentUserId).updateData([
                "groups": FieldValue.arrayUnion([docRef.documentID])
            ])
            
            await fetchUserGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func createMockGroup(name: String, description: String?) async {
        print("GroupViewModel: Creating mock group: \(name)")
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        } catch {
            print("GroupViewModel: Error during mock delay: \(error)")
        }
        
        let mockGroup = Group(name: name, description: description, createdBy: "mockuser")
        userGroups.append(mockGroup)
        
        isLoading = false
        print("GroupViewModel: Mock group created successfully")
    }
    
    func joinGroup(inviteCode: String) async {
        // Check if we're in bypass mode or mock mode
        let isBypassMode = authViewModel?.isAuthenticated == true && Auth.auth().currentUser == nil
        let shouldUseMock = isMockMode || isBypassMode
        
        print("GroupViewModel: Joining group - Mock mode: \(isMockMode), Bypass mode: \(isBypassMode), Should use mock: \(shouldUseMock)")
        
        if shouldUseMock {
            await joinMockGroup(inviteCode: inviteCode)
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let query = db.collection("groups").whereField("inviteCode", isEqualTo: inviteCode)
            let snapshot = try await query.getDocuments()
            
            guard let document = snapshot.documents.first else {
                errorMessage = "Invalid invite code"
                isLoading = false
                return
            }
            
            let group = try document.data(as: Group.self)
            
            // Check if user is already a member
            if group.members.contains(currentUserId) {
                errorMessage = "You are already a member of this group"
                isLoading = false
                return
            }
            
            // Add user to group
            try await db.collection("groups").document(document.documentID).updateData([
                "members": FieldValue.arrayUnion([currentUserId])
            ])
            
            // Add group to user's groups
            try await db.collection("users").document(currentUserId).updateData([
                "groups": FieldValue.arrayUnion([document.documentID])
            ])
            
            await fetchUserGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func joinMockGroup(inviteCode: String) async {
        print("GroupViewModel: Joining mock group with code: \(inviteCode)")
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        } catch {
            print("GroupViewModel: Error during mock delay: \(error)")
        }
        
        // Simulate finding a group with the invite code
        if let existingGroup = userGroups.first(where: { $0.inviteCode == inviteCode }) {
            errorMessage = "You are already a member of this group"
        } else {
            // Create a new mock group with the invite code
            let mockGroup = Group(name: "Joined Group", description: "Group joined via invite code", createdBy: "otheruser")
            userGroups.append(mockGroup)
            print("GroupViewModel: Mock group joined successfully")
        }
        
        isLoading = false
    }
    
    func fetchUserGroups() {
        // Check if we're in bypass mode or mock mode
        let isBypassMode = authViewModel?.isAuthenticated == true && Auth.auth().currentUser == nil
        let shouldUseMock = isMockMode || isBypassMode
        
        print("GroupViewModel: Fetching groups - Mock mode: \(isMockMode), Bypass mode: \(isBypassMode), Should use mock: \(shouldUseMock)")
        
        if shouldUseMock {
            print("GroupViewModel: Mock mode - using existing mock groups")
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("groups")
            .whereField("members", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.userGroups = []
                        return
                    }
                    
                    self?.userGroups = documents.compactMap { document in
                        try? document.data(as: Group.self)
                    }
                }
            }
    }
    
    func leaveGroup(groupId: String) async {
        // Check if we're in bypass mode or mock mode
        let isBypassMode = authViewModel?.isAuthenticated == true && Auth.auth().currentUser == nil
        let shouldUseMock = isMockMode || isBypassMode
        
        print("GroupViewModel: Leaving group - Mock mode: \(isMockMode), Bypass mode: \(isBypassMode), Should use mock: \(shouldUseMock)")
        
        if shouldUseMock {
            await leaveMockGroup(groupId: groupId)
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Remove user from group
            try await db.collection("groups").document(groupId).updateData([
                "members": FieldValue.arrayRemove([currentUserId])
            ])
            
            // Remove group from user's groups
            try await db.collection("users").document(currentUserId).updateData([
                "groups": FieldValue.arrayRemove([groupId])
            ])
            
            await fetchUserGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func leaveMockGroup(groupId: String) async {
        print("GroupViewModel: Leaving mock group: \(groupId)")
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } catch {
            print("GroupViewModel: Error during mock delay: \(error)")
        }
        
        // Remove the group from the list
        userGroups.removeAll { $0.id == groupId }
        
        isLoading = false
        print("GroupViewModel: Mock group left successfully")
    }
} 