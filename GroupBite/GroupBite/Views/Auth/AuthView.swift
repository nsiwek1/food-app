import SwiftUI

struct AuthView: View {
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Hero section
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        Text("GroupBite")
                            .font(AppTypography.largeTitle)
                            .foregroundColor(AppColors.primary)
                            .fontWeight(.bold)
                        
                        Text("Find restaurants together with friends")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Text("Create groups, swipe through restaurants, and discover amazing places to eat with your friends.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    
                    Spacer()
                    
                    // Feature highlights
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        FeatureRow(icon: "person.3.fill", title: "Group Dining", description: "Create groups and vote together")
                        FeatureRow(icon: "heart.fill", title: "Smart Matching", description: "AI-powered restaurant recommendations")
                        FeatureRow(icon: "location.fill", title: "Local Discovery", description: "Find hidden gems in your area")
                    }
                    
                    Spacer()
                }
                .padding(AppSpacing.xxl)
                .frame(maxWidth: geometry.size.width * 0.5)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.primary.opacity(0.05),
                            AppColors.secondary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Right side - Auth form
                VStack(spacing: AppSpacing.xl) {
                    Spacer()
                    
                    VStack(spacing: AppSpacing.lg) {
                        // Header
                        VStack(spacing: AppSpacing.md) {
                            Text(isSignUp ? "Create Account" : "Welcome Back")
                                .font(AppTypography.title1)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(isSignUp ? "Join GroupBite and start discovering restaurants with friends" : "Sign in to continue your food journey")
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Form
                        VStack(spacing: AppSpacing.lg) {
                            // Email field
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Email")
                                    .font(AppTypography.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .textContentType(.emailAddress)
                                    #if os(iOS)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    #endif
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Password")
                                    .font(AppTypography.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .textContentType(isSignUp ? .newPassword : .password)
                            }
                            
                            // Confirm password field (sign up only)
                            if isSignUp {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    Text("Confirm Password")
                                        .font(AppTypography.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    SecureField("Confirm your password", text: $confirmPassword)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .textContentType(.newPassword)
                                }
                            }
                        }
                        
                        // Action buttons
                        VStack(spacing: AppSpacing.md) {
                            PrimaryButton(
                                isSignUp ? "Create Account" : "Sign In",
                                icon: isSignUp ? "person.badge.plus" : "arrow.right",
                                isLoading: isLoading
                            ) {
                                handleAuth()
                            }
                            
                            SecondaryButton(
                                isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up",
                                icon: isSignUp ? "arrow.left" : "person.badge.plus"
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isSignUp.toggle()
                                    email = ""
                                    password = ""
                                    confirmPassword = ""
                                    showError = false
                                }
                            }
                        }
                        
                        // Error message
                        if showError {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.error)
                                
                                Text(errorMessage)
                                    .font(AppTypography.caption1)
                                    .foregroundColor(AppColors.error)
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(AppCornerRadius.md)
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(AppSpacing.xl)
                    .frame(maxWidth: 400)
                    
                    Spacer()
                }
                .frame(maxWidth: geometry.size.width * 0.5)
                .background(AppColors.surface)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func handleAuth() {
        guard !email.isEmpty && !password.isEmpty else {
            showError(message: "Please fill in all fields")
            return
        }
        
        if isSignUp {
            guard password == confirmPassword else {
                showError(message: "Passwords don't match")
                return
            }
            
            guard password.count >= 6 else {
                showError(message: "Password must be at least 6 characters")
                return
            }
        }
        
        isLoading = true
        showError = false
        
        Task {
            do {
                if isSignUp {
                    try await authViewModel.signUp(email: email, password: password, username: email, displayName: email)
                } else {
                    try await authViewModel.signIn(email: email, password: password)
                }
                
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showError = true
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .frame(width: 40, height: 40)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(AppCornerRadius.md)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(AppSpacing.md)
            .background(AppColors.surfaceSecondary)
            .cornerRadius(AppCornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .font(AppTypography.body)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
} 