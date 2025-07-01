import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingDebugInfo = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("GroupBite")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Find restaurants together")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                // Debug Info
                if showingDebugInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Info:")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Mock Mode: \(authViewModel.isMockMode ? "Yes" : "No")")
                            .font(.caption)
                        Text("Authenticated: \(authViewModel.isAuthenticated ? "Yes" : "No")")
                            .font(.caption)
                        Text("Loading: \(authViewModel.isLoading ? "Yes" : "No")")
                            .font(.caption)
                        if let error = authViewModel.errorMessage {
                            Text("Error: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Sign In Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
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
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                    
                    Button(action: signIn) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 30)
                
                // Sign Up Link
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal, 30)
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            showingSignUp = true
                        }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                    }
                }
                
                // Debug Button
                Button("Toggle Debug Info") {
                    showingDebugInfo.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                // Bypass Auth Button
                Button("Bypass Auth (Skip Sign In)") {
                    print("🚀 Bypass auth button clicked from SignInView!")
                    Task {
                        await authViewModel.bypassAuth()
                    }
                }
                .font(.caption)
                .foregroundColor(.purple)
                
                Spacer()
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert("LevelDB Database Lock Error", isPresented: $authViewModel.showLevelDBFixInstructions) {
                Button("Copy Command") {
                    let command = "rm -rf ~/Library/Containers/com.groupbite.GroupBite/Data/Library/Application\\ Support/firestore/"
                    #if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(command, forType: .string)
                    #endif
                }
                Button("OK") { }
            } message: {
                Text("The Firestore database is locked. To fix this:\n\n1. Quit the app completely\n2. Open Terminal\n3. Run this command:\nrm -rf ~/Library/Containers/com.groupbite.GroupBite/Data/Library/Application\\ Support/firestore/\n4. Restart the app\n\nOr continue using mock mode for testing.")
            }
        }
    }
    
    private func signIn() {
        Task {
            await authViewModel.signIn(email: email, password: password)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
} 