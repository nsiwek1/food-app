import Foundation
import Security
import FirebaseAuth

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // Request Keychain access explicitly
    func requestKeychainAccess() -> Bool {
        print("KeychainManager: Requesting Keychain access...")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "GroupBiteTest",
            kSecAttrService as String: "GroupBite",
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecValueData as String: "test".data(using: .utf8)!
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("KeychainManager: Successfully added test item to Keychain")
            // Clean up the test item
            SecItemDelete(query as CFDictionary)
            return true
        } else if status == errSecDuplicateItem {
            print("KeychainManager: Test item already exists in Keychain")
            // Clean up the test item
            SecItemDelete(query as CFDictionary)
            return true
        } else {
            print("KeychainManager: Failed to access Keychain - Status: \(status)")
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                print("KeychainManager: Error description: \(errorMessage)")
            } else {
                print("KeychainManager: Error description: Unknown error")
            }
            return false
        }
    }
    
    // Clear all Keychain entries for the app
    func clearKeychainEntries() {
        print("KeychainManager: Clearing Keychain entries...")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "GroupBite"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        print("KeychainManager: Clear status: \(status)")
    }
    
    // Check if Keychain is accessible
    func isKeychainAccessible() -> Bool {
        return requestKeychainAccess()
    }
    
    // Configure Firebase Auth with proper Keychain settings
    func configureFirebaseAuth() {
        print("KeychainManager: Configuring Firebase Auth...")
        
        do {
            // Try to set a custom access group for Firebase Auth
            try Auth.auth().useUserAccessGroup("$(AppIdentifierPrefix)com.groupbite.GroupBite")
            print("KeychainManager: Successfully set Firebase Auth access group")
        } catch {
            print("KeychainManager: Failed to set Firebase Auth access group: \(error)")
            
            // Try without access group
            do {
                try Auth.auth().useUserAccessGroup(nil)
                print("KeychainManager: Successfully cleared Firebase Auth access group")
            } catch {
                print("KeychainManager: Failed to clear Firebase Auth access group: \(error)")
            }
        }
    }
} 