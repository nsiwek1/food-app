import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var groupViewModel = GroupViewModel()
    @State private var showingCreateGroup = false
    @State private var showingJoinGroup = false
    @State private var inviteCode = ""
    @State private var navigateToCreateGroup = false
    @State private var apiTestResult: String = ""
    @State private var isTestingAPI = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header
                headerView
                Divider().background(AppColors.border)
                
                // Main Content
                if groupViewModel.isLoading {
                    loadingView
                } else if groupViewModel.userGroups.isEmpty {
                    emptyStateView
                } else {
                    groupsListView
                }
            }
            .frame(minWidth: 350, minHeight: 500)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
        .sheet(isPresented: $navigateToCreateGroup) {
            CreateGroupView(groupViewModel: groupViewModel)
        }
        .alert("Join Group", isPresented: $showingJoinGroup) {
            TextField("Enter invite code", text: $inviteCode)
                .textFieldStyle(ModernTextFieldStyle())
                #if os(iOS)
                .textInputAutocapitalization(.characters)
                #endif
            Button("Join") {
                joinGroup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the invite code provided by your friend")
        }
        .alert("API Test Result", isPresented: .constant(!apiTestResult.isEmpty)) {
            Button("OK") {
                apiTestResult = ""
            }
        } message: {
            Text(apiTestResult)
        }
        .onAppear {
            groupViewModel.setAuthViewModel(authViewModel)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("My Groups")
                .font(AppTypography.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { navigateToCreateGroup = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }
            .help("Create Group")
            Button("Sign Out") {
                authViewModel.signOut()
            }
            .foregroundColor(AppColors.error)
            .font(AppTypography.subheadline)
            .fontWeight(.medium)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
                .foregroundColor(AppColors.primary)
            
            Text("Loading groups...")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            VStack(spacing: AppSpacing.xl) {
                // Hero icon
                VStack(spacing: AppSpacing.lg) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(AppColors.primary)
                        .background(
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 120, height: 120)
                        )
                    
                    VStack(spacing: AppSpacing.md) {
                        Text("No Groups Yet")
                            .font(AppTypography.title1)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Create a group or join one to start finding restaurants together")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                }
                
                // Action buttons
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton("Create Group", icon: "plus.circle.fill") {
                        navigateToCreateGroup = true
                    }
                    
                    SecondaryButton("Join Group", icon: "person.badge.plus") {
                        showingJoinGroup = true
                    }
                    
                    // API Test Button
                    Button(action: testAPI) {
                        HStack(spacing: AppSpacing.sm) {
                            if isTestingAPI {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(AppColors.success)
                            } else {
                                Image(systemName: "network")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.success)
                            }
                            Text(isTestingAPI ? "Testing..." : "Test API")
                                .font(AppTypography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.success)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.success.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(AppColors.success, lineWidth: 2)
                        )
                        .cornerRadius(AppCornerRadius.md)
                    }
                    .disabled(isTestingAPI)
                    
                    // Direct Restaurant Search Test
                    Button(action: testRestaurantSearch) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.secondary)
                            Text("Test Restaurant Search")
                                .font(AppTypography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.secondary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(AppColors.secondary, lineWidth: 2)
                        )
                        .cornerRadius(AppCornerRadius.md)
                    }
                }
                .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
        }
    }
    
    private var groupsListView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(groupViewModel.userGroups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        GroupRowView(group: group)
                    }
                    .listRowBackground(AppColors.surface)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: AppSpacing.sm, leading: AppSpacing.lg, bottom: AppSpacing.sm, trailing: AppSpacing.lg))
                }
                .onDelete(perform: deleteGroups)
            }
            .listStyle(PlainListStyle())
            .refreshable {
                groupViewModel.fetchUserGroups()
            }
            
            // Bottom action buttons
            VStack(spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.md) {
                    PrimaryButton("Create Group", icon: "plus.circle.fill") {
                        navigateToCreateGroup = true
                    }
                    
                    SecondaryButton("Join Group", icon: "person.badge.plus") {
                        showingJoinGroup = true
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.surface)
            .overlay(
                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1),
                alignment: .top
            )
        }
    }
    
    private func joinGroup() {
        guard !inviteCode.isEmpty else { return }
        
        Task {
            await groupViewModel.joinGroup(inviteCode: inviteCode.uppercased())
            inviteCode = ""
        }
    }
    
    private func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            let group = groupViewModel.userGroups[index]
            Task {
                await groupViewModel.leaveGroup(groupId: group.id ?? "")
            }
        }
    }
    
    private func testAPI() {
        isTestingAPI = true
        
        Task {
            let result = await APIConfig.testAPIKey()
            
            await MainActor.run {
                isTestingAPI = false
                if result {
                    apiTestResult = "✅ API Key is working! Google Places API is ready to use."
                } else {
                    apiTestResult = "❌ API Key test failed. Please check your API key configuration and internet connection."
                }
            }
        }
    }
    
    private func testRestaurantSearch() {
        print("🧪 Testing restaurant search directly...")
        
        Task {
            let restaurantViewModel = RestaurantViewModel()
            await restaurantViewModel.searchRestaurants(
                query: "pizza",
                location: nil,
                radius: 5000,
                priceLevel: 0,
                types: ["restaurant"]
            )
            
            await MainActor.run {
                if restaurantViewModel.restaurants.isEmpty {
                    apiTestResult = "❌ Restaurant search failed - no restaurants returned"
                } else {
                    apiTestResult = "✅ Restaurant search successful! Found \(restaurantViewModel.restaurants.count) restaurants"
                }
            }
        }
    }
}

struct GroupRowView: View {
    let group: Group
    
    var body: some View {
        CardView(padding: AppSpacing.lg, shadow: AppShadows.small) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(group.name)
                            .font(AppTypography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if let description = group.description {
                            Text(description)
                                .font(AppTypography.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(group.members.count)")
                                .font(AppTypography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        BadgeView("Code: \(group.inviteCode)", color: AppColors.primary, size: .small)
                    }
                }
                
                // Footer
                HStack {
                    Text("Created \(group.createdAt, style: .relative) ago")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Spacer()
                    
                    if group.isActive {
                        BadgeView("Active", color: AppColors.success, size: .small)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
} 