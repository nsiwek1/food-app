//
//  GroupBiteApp.swift
//  GroupBite
//
//  Created by Natalia_Mac on 6/21/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@main
struct GroupBiteApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        print("GroupBiteApp: Initializing...")
        
        // Configure Keychain access first
        print("GroupBiteApp: Testing Keychain access...")
        let keychainAccessible = KeychainManager.shared.isKeychainAccessible()
        print("GroupBiteApp: Keychain accessible: \(keychainAccessible)")
        
        // Configure Firebase with Keychain error handling
        do {
            FirebaseApp.configure()
            print("GroupBiteApp: Firebase configured successfully")
            
            if keychainAccessible {
                // Configure Firebase Auth with proper Keychain settings
                KeychainManager.shared.configureFirebaseAuth()
                print("GroupBiteApp: Firebase Auth configured with Keychain settings")
            } else {
                print("GroupBiteApp: Keychain not accessible - Firebase Auth may have issues")
            }
            
        } catch {
            print("GroupBiteApp: Firebase configuration failed: \(error)")
            print("GroupBiteApp: Error details - Domain: \(error._domain), Code: \(error._code)")
            
            // Try to configure without Auth if there's a Keychain issue
            if error._domain == "NSOSStatusErrorDomain" || 
               error.localizedDescription.contains("Keychain") ||
               error.localizedDescription.contains("keychain") {
                print("GroupBiteApp: Detected Keychain error, configuring Firebase without Auth...")
                FirebaseApp.configure()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
                .background(AppColors.background)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
    }
}
