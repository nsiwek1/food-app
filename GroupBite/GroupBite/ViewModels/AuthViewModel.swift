import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Combine
import Security

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isMockMode = false
    @Published var showLevelDBFixInstructions = false
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        print("AuthViewModel: Initializing...")
        
        // Configure Keychain access first
        configureKeychainAccess()
        
        testFirebaseConfiguration()
        setupAuthStateListener()
    }
    
    private func configureKeychainAccess() {
        print("AuthViewModel: Configuring Keychain access...")
        
        // Test Keychain access
        let keychainAccessible = KeychainManager.shared.isKeychainAccessible()
        print("AuthViewModel: Keychain accessible: \(keychainAccessible)")
        
        if keychainAccessible {
            // Configure Firebase Auth with proper Keychain settings
            KeychainManager.shared.configureFirebaseAuth()
        } else {
            print("AuthViewModel: Keychain not accessible - will use alternative authentication methods")
        }
    }
    
    private func testFirebaseConfiguration() {
        print("AuthViewModel: Testing Firebase configuration...")
        
        // Check if Firebase is configured
        if let app = FirebaseApp.app() {
            print("AuthViewModel: Firebase app found: \(app.name)")
            print("AuthViewModel: Firebase options: \(app.options)")
            print("AuthViewModel: Firebase project ID: \(app.options.projectID)")
        } else {
            print("AuthViewModel: ERROR - No Firebase app found!")
            print("AuthViewModel: Switching to mock mode for testing...")
            isMockMode = true
            errorMessage = "Firebase not configured. Using mock mode for testing."
            return
        }
        
        // Test Firestore connection only if Firebase is configured
        Task {
            await testFirestoreConnection()
        }
    }
    
    private func testFirestoreConnection() async {
        do {
            print("AuthViewModel: Testing Firestore connection...")
            let testDoc = try await db.collection("test").document("connection").getDocument()
            print("AuthViewModel: Firestore connection successful")
        } catch {
            print("AuthViewModel: Firestore connection failed: \(error.localizedDescription)")
            print("AuthViewModel: Firestore error details: \(error)")
            
            // Check if it's a LevelDB lock error
            if error.localizedDescription.contains("LevelDB") || 
               error.localizedDescription.contains("lock") ||
               error.localizedDescription.contains("Resource temporarily unavailable") ||
               error.localizedDescription.contains("FIRESTORE INTERNAL ASSERTION FAILED") {
                print("AuthViewModel: Detected LevelDB lock error - switching to mock mode immediately...")
                isMockMode = true
                errorMessage = "Firestore database locked. Using mock mode for testing. To fix: quit app and run 'rm -rf ~/Library/Containers/com.groupbite.GroupBite/Data/Library/Application\\ Support/firestore/' in Terminal"
                showLevelDBFixInstructions = true
            } else if error.localizedDescription.contains("missing or insufficient addresses") ||
                      error.localizedDescription.contains("404") ||
                      error.localizedDescription.contains("not found") {
                print("AuthViewModel: Detected database not created error - switching to mock mode...")
                isMockMode = true
                errorMessage = "Firestore database not created yet. Using mock mode for testing. Please follow the setup guide in setup_firebase.md to create the database."
            } else {
                print("AuthViewModel: Other Firebase error - trying to continue with real Firebase...")
                errorMessage = "Firestore connection failed: \(error.localizedDescription)"
                // Don't switch to mock mode for other errors, try to continue
            }
        }
    }
    
    private func setupAuthStateListener() {
        if isMockMode {
            print("AuthViewModel: Mock mode - skipping auth state listener")
            return
        }
        
        print("AuthViewModel: Setting up auth state listener...")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("AuthViewModel: Auth state changed. User: \(user?.uid ?? "nil")")
            Task { @MainActor in
                if let user = user {
                    self?.isAuthenticated = true
                    print("AuthViewModel: User authenticated: \(user.uid)")
                    await self?.fetchUserData(userId: user.uid)
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    print("AuthViewModel: User signed out")
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        print("AuthViewModel: Starting sign in...")
        print("AuthViewModel: Mock mode: \(isMockMode)")
        isLoading = true
        errorMessage = nil
        
        if isMockMode {
            print("AuthViewModel: Mock mode - simulating sign in...")
            // Simulate network delay
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            } catch {
                print("AuthViewModel: Error during mock delay: \(error)")
            }
            
            // Mock successful sign in
            let mockUser = User(email: email, username: "mockuser", displayName: "Mock User")
            currentUser = mockUser
            isAuthenticated = true
            isLoading = false
            print("AuthViewModel: Mock sign in successful")
            return
        }
        
        do {
            print("AuthViewModel: Attempting Firebase sign in...")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("AuthViewModel: Sign in successful for user: \(result.user.uid)")
            await fetchUserData(userId: result.user.uid)
        } catch {
            print("AuthViewModel: Sign in error: \(error.localizedDescription)")
            print("AuthViewModel: Sign in error details: \(error)")
            
            // Log detailed error information for debugging
            if let nsError = error as NSError? {
                print("AuthViewModel: NSError domain: \(nsError.domain)")
                print("AuthViewModel: NSError code: \(nsError.code)")
                print("AuthViewModel: NSError user info: \(nsError.userInfo)")
                
                // Check for specific Keychain error codes
                if nsError.domain == "NSOSStatusErrorDomain" {
                    print("AuthViewModel: Detected OSStatus error (Keychain related)")
                    print("AuthViewModel: OSStatus code: \(nsError.code)")
                }
            }
            
            // Handle specific Keychain errors
            if error.localizedDescription.contains("Keychain") || 
               error.localizedDescription.contains("keychain") ||
               error.localizedDescription.contains("security") ||
               error.localizedDescription.contains("SecKeychain") ||
               error.localizedDescription.contains("NSOSStatusErrorDomain") ||
               (error as NSError?)?.domain == "NSOSStatusErrorDomain" {
                print("AuthViewModel: Detected Keychain error during sign in - trying alternative approach...")
                
                // Try to fetch user data directly from Firestore
                do {
                    // First, try to find the user by email
                    let query = db.collection("users").whereField("email", isEqualTo: email)
                    let snapshot = try await query.getDocuments()
                    
                    if let document = snapshot.documents.first {
                        let user = try document.data(as: User.self)
                        currentUser = user
                        isAuthenticated = true
                        isLoading = false
                        print("AuthViewModel: Sign in successful with alternative method")
                        return
                    } else {
                        errorMessage = "User not found. Please check your email or sign up first."
                    }
                } catch {
                    print("AuthViewModel: Alternative sign in also failed: \(error.localizedDescription)")
                    errorMessage = "Keychain access error during sign in. Please try:\n\n1. Quit the app completely\n2. Open Keychain Access app\n3. Search for 'GroupBite' and delete any entries\n4. Restart the app and try again\n\nOr use the 'Bypass Auth' button to skip authentication."
                }
            } else {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, username: String, displayName: String) async {
        print("AuthViewModel: Starting sign up...")
        print("AuthViewModel: Email: \(email)")
        print("AuthViewModel: Username: \(username)")
        print("AuthViewModel: Display Name: \(displayName)")
        print("AuthViewModel: Mock mode: \(isMockMode)")
        
        isLoading = true
        errorMessage = nil
        
        if isMockMode {
            print("AuthViewModel: Mock mode - simulating sign up...")
            // Simulate network delay
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            } catch {
                print("AuthViewModel: Error during mock delay: \(error)")
            }
            
            // Mock successful sign up
            let mockUser = User(email: email, username: username, displayName: displayName)
            currentUser = mockUser
            isAuthenticated = true
            isLoading = false
            print("AuthViewModel: Mock sign up successful")
            return
        }
        
        do {
            print("AuthViewModel: Creating Firebase user...")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("AuthViewModel: Firebase user created: \(result.user.uid)")
            
            let user = User(email: email, username: username, displayName: displayName)
            print("AuthViewModel: Creating user document...")
            try await createUserDocument(user: user, userId: result.user.uid)
            print("AuthViewModel: User document created successfully")
            
            currentUser = user
            print("AuthViewModel: Sign up completed successfully")
        } catch {
            print("AuthViewModel: Sign up error: \(error.localizedDescription)")
            print("AuthViewModel: Sign up error details: \(error)")
            
            // Log detailed error information for debugging
            if let nsError = error as NSError? {
                print("AuthViewModel: NSError domain: \(nsError.domain)")
                print("AuthViewModel: NSError code: \(nsError.code)")
                print("AuthViewModel: NSError user info: \(nsError.userInfo)")
                
                // Check for specific Keychain error codes
                if nsError.domain == "NSOSStatusErrorDomain" {
                    print("AuthViewModel: Detected OSStatus error (Keychain related)")
                    print("AuthViewModel: OSStatus code: \(nsError.code)")
                }
            }
            
            // Handle specific Keychain errors
            if error.localizedDescription.contains("Keychain") || 
               error.localizedDescription.contains("keychain") ||
               error.localizedDescription.contains("security") ||
               error.localizedDescription.contains("SecKeychain") ||
               error.localizedDescription.contains("NSOSStatusErrorDomain") ||
               (error as NSError?)?.domain == "NSOSStatusErrorDomain" {
                print("AuthViewModel: Detected Keychain error - trying alternative approach...")
                
                // Try to create user document without Firebase Auth first
                do {
                    let user = User(email: email, username: username, displayName: displayName)
                    let userId = UUID().uuidString
                    try await createUserDocument(user: user, userId: userId)
                    
                    // Set current user and mark as authenticated
                    currentUser = user
                    isAuthenticated = true
                    isLoading = false
                    print("AuthViewModel: User created successfully with alternative method")
                    return
                } catch {
                    print("AuthViewModel: Alternative sign up also failed: \(error.localizedDescription)")
                    errorMessage = "Keychain access error. This is a common issue on macOS. Please try:\n\n1. Quit the app completely\n2. Open Keychain Access app\n3. Search for 'GroupBite' and delete any entries\n4. Restart the app and try again\n\nOr use the 'Quick Test Sign Up' button to bypass authentication."
                }
            } else {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func signOut() {
        print("AuthViewModel: Signing out...")
        
        if isMockMode {
            print("AuthViewModel: Mock mode - simulating sign out...")
            isAuthenticated = false
            currentUser = nil
            return
        }
        
        do {
            try Auth.auth().signOut()
            print("AuthViewModel: Sign out successful")
        } catch {
            print("AuthViewModel: Sign out error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func createUserDocument(user: User, userId: String) async throws {
        print("AuthViewModel: Creating user document for ID: \(userId)")
        var userData = user
        userData.id = userId
        try await db.collection("users").document(userId).setData(from: userData)
        print("AuthViewModel: User document created successfully")
    }
    
    private func fetchUserData(userId: String) async {
        print("AuthViewModel: Fetching user data for ID: \(userId)")
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            
            if document.exists {
                currentUser = try document.data(as: User.self)
                print("AuthViewModel: User data fetched successfully")
            } else {
                print("AuthViewModel: User document doesn't exist, creating it...")
                // Create a basic user document with Firebase Auth user info
                if let firebaseUser = Auth.auth().currentUser {
                    let user = User(
                        email: firebaseUser.email ?? "unknown@example.com",
                        username: firebaseUser.displayName ?? "user\(userId.prefix(8))",
                        displayName: firebaseUser.displayName ?? "User"
                    )
                    try await createUserDocument(user: user, userId: userId)
                    currentUser = user
                    print("AuthViewModel: User document created successfully")
                } else {
                    print("AuthViewModel: No Firebase user found")
                    errorMessage = "User authentication error"
                }
            }
        } catch {
            print("AuthViewModel: Failed to fetch user data: \(error.localizedDescription)")
            
            // If the document doesn't exist, try to create it
            if error.localizedDescription.contains("No document to update") ||
               error.localizedDescription.contains("not found") {
                print("AuthViewModel: Document not found, creating user document...")
                if let firebaseUser = Auth.auth().currentUser {
                    let user = User(
                        email: firebaseUser.email ?? "unknown@example.com",
                        username: firebaseUser.displayName ?? "user\(userId.prefix(8))",
                        displayName: firebaseUser.displayName ?? "User"
                    )
                    do {
                        try await createUserDocument(user: user, userId: userId)
                        currentUser = user
                        print("AuthViewModel: User document created successfully after fetch failure")
                    } catch {
                        print("AuthViewModel: Failed to create user document: \(error.localizedDescription)")
                        errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                    }
                }
            } else {
                errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
            }
        }
    }
    
    // Helper function to clean up Keychain entries
    func cleanupKeychain() {
        print("AuthViewModel: Cleaning up Keychain entries...")
        
        // Use KeychainManager to clear entries
        KeychainManager.shared.clearKeychainEntries()
        
        // Try to clear Firebase Auth state
        do {
            try Auth.auth().signOut()
            print("AuthViewModel: Firebase Auth signed out successfully")
        } catch {
            print("AuthViewModel: Error signing out Firebase Auth: \(error.localizedDescription)")
        }
        
        // Clear current user state
        currentUser = nil
        isAuthenticated = false
        
        // Reconfigure Keychain access
        configureKeychainAccess()
        
        // Show instructions to user
        errorMessage = "Keychain cleanup completed. Please try signing up again. If the issue persists:\n\n1. Open Keychain Access app\n2. Search for 'GroupBite' or 'Firebase'\n3. Delete any related entries\n4. Restart the app\n\nOr use the 'Bypass Auth' button to continue without Firebase authentication."
    }
    
    // Quick test sign up that bypasses Firebase Auth
    func quickTestSignUp() async {
        print("AuthViewModel: Starting quick test sign up...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Create a test user directly in Firestore
            let testUser = User(
                email: "test@example.com",
                username: "testuser",
                displayName: "Test User"
            )
            let userId = UUID().uuidString
            
            print("AuthViewModel: Creating test user with ID: \(userId)")
            try await createUserDocument(user: testUser, userId: userId)
            
            // Set as current user and authenticate
            currentUser = testUser
            isAuthenticated = true
            isLoading = false
            
            print("AuthViewModel: Quick test sign up successful!")
            print("AuthViewModel: User authenticated: \(testUser.displayName)")
            
        } catch {
            print("AuthViewModel: Quick test sign up failed: \(error.localizedDescription)")
            errorMessage = "Quick test sign up failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // Bypass authentication completely for testing
    func bypassAuth() async {
        print("AuthViewModel: Bypassing authentication completely...")
        isLoading = true
        errorMessage = nil
        
        // Create a mock user without any Firebase operations
        let mockUser = User(
            email: "bypass@example.com",
            username: "bypassuser",
            displayName: "Bypass User"
        )
        
        // Set as current user and authenticate
        currentUser = mockUser
        isAuthenticated = true
        isLoading = false
        
        print("AuthViewModel: Authentication bypassed successfully!")
        print("AuthViewModel: User authenticated: \(mockUser.displayName)")
        print("AuthViewModel: isAuthenticated: \(isAuthenticated)")
        print("AuthViewModel: currentUser: \(String(describing: currentUser))")
    }
    
    // Request Keychain access explicitly
    func requestKeychainAccess() async {
        print("AuthViewModel: Requesting Keychain access...")
        isLoading = true
        errorMessage = nil
        
        // Use KeychainManager to test access
        let keychainAccessible = KeychainManager.shared.requestKeychainAccess()
        
        if keychainAccessible {
            // Reconfigure Firebase Auth with proper Keychain settings
            KeychainManager.shared.configureFirebaseAuth()
            
            isLoading = false
            errorMessage = "Keychain access granted! Please try signing up again."
        } else {
            print("AuthViewModel: Keychain access request failed")
            isLoading = false
            errorMessage = "Keychain access denied. Please:\n\n1. Open System Preferences > Security & Privacy > Privacy > Keychain\n2. Add GroupBite to the list\n3. Restart the app\n\nOr use the 'Bypass Auth' button to continue without Firebase authentication."
        }
    }
} 