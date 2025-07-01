import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var showingDebugInfo = false
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !username.isEmpty && 
        !displayName.isEmpty && 
        password == confirmPassword &&
        password.count >= 6 &&
        username.count >= 3
    }
    
    private var passwordMatchError: String? {
        if !confirmPassword.isEmpty && password != confirmPassword {
            return "Passwords don't match"
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Join GroupBite to start finding restaurants with friends")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Sign Up Form
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.headline)
                    
                    TextField("Enter your full name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                    
                    TextField("Choose a username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                    
                    if username.count > 0 && username.count < 3 {
                        Text("Username must be at least 3 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        #endif
                        .disableAutocorrection(true)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                    
                    SecureField("Create a password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if password.count > 0 && password.count < 6 {
                        Text("Password must be at least 6 characters")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.headline)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let error = passwordMatchError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Debug Info
                if showingDebugInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Info:")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Form Valid: \(isFormValid ? "Yes" : "No")")
                            .font(.caption)
                        Text("Email: \(email)")
                            .font(.caption)
                        Text("Username: \(username)")
                            .font(.caption)
                        Text("Display Name: \(displayName)")
                            .font(.caption)
                        Text("Password Length: \(password.count)")
                            .font(.caption)
                        Text("Loading: \(authViewModel.isLoading ? "Yes" : "No")")
                            .font(.caption)
                        Text("Authenticated: \(authViewModel.isAuthenticated ? "Yes" : "No")")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let errorMessage = authViewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: signUp) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.orange : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || authViewModel.isLoading)
                
                // Debug Button
                Button("Toggle Debug Info") {
                    showingDebugInfo.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                // Keychain Cleanup Button
                Button("Fix Keychain Issues") {
                    authViewModel.cleanupKeychain()
                }
                .font(.caption)
                .foregroundColor(.orange)
                
                // Quick Test Sign Up Button
                Button("Quick Test Sign Up (Bypass Auth)") {
                    print("🔧 Quick Test Sign Up button clicked!")
                    Task {
                        print("🔧 Starting quick test sign up task...")
                        await authViewModel.quickTestSignUp()
                        print("🔧 Quick test sign up task completed!")
                    }
                }
                .font(.caption)
                .foregroundColor(.green)
                
                // Simple Test Button
                Button("Simple Test (No Auth)") {
                    print("🧪 Simple test button clicked!")
                    authViewModel.isAuthenticated = true
                    authViewModel.currentUser = User(email: "test@test.com", username: "testuser", displayName: "Test User")
                    print("🧪 User set as authenticated!")
                }
                .font(.caption)
                .foregroundColor(.red)
                
                // Bypass Auth Button
                Button("Bypass Auth Completely") {
                    print("🚀 Bypass auth button clicked!")
                    Task {
                        await authViewModel.bypassAuth()
                    }
                }
                .font(.caption)
                .foregroundColor(.purple)
                
                // Request Keychain Access Button
                Button("Request Keychain Access") {
                    print("🔑 Requesting Keychain access...")
                    Task {
                        await authViewModel.requestKeychainAccess()
                    }
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationTitle("Sign Up")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private func signUp() {
        print("SignUp: Starting sign up process...")
        print("SignUp: Email: \(email)")
        print("SignUp: Username: \(username)")
        print("SignUp: Display Name: \(displayName)")
        print("SignUp: Password length: \(password.count)")
        
        Task {
            await authViewModel.signUp(
                email: email,
                password: password,
                username: username,
                displayName: displayName
            )
            
            print("SignUp: Auth completed. isAuthenticated: \(authViewModel.isAuthenticated)")
            print("SignUp: Error message: \(authViewModel.errorMessage ?? "None")")
            
            if authViewModel.isAuthenticated {
                print("SignUp: Dismissing view...")
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
} 