import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var groupViewModel: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            headerView
            Divider().background(AppColors.border)
            
            VStack(spacing: AppSpacing.xl) {
                // Header Icon
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(AppColors.primary)
                        .background(
                            Circle()
                                .fill(AppColors.primary.opacity(0.1))
                                .frame(width: 100, height: 100)
                        )
                    Text("Create a New Group")
                        .font(AppTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                VStack(spacing: AppSpacing.lg) {
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(ModernTextFieldStyle())
                        .font(AppTypography.body)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(maxWidth: 400)
                    
                    TextField("Description (optional)", text: $groupDescription)
                        .textFieldStyle(ModernTextFieldStyle())
                        .font(AppTypography.body)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(maxWidth: 400)
                }
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(AppColors.error)
                        .font(AppTypography.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                
                PrimaryButton(isLoading ? "Creating..." : "Create Group", icon: "plus.circle.fill", isLoading: isLoading) {
                    createGroup()
                }
                .disabled(isLoading || groupName.isEmpty)
                .frame(maxWidth: 400)
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 400, minHeight: 500)
        .background(AppColors.background)
    }
    
    private var headerView: some View {
        HStack {
            Text("Create Group")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Close")
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
    }
    
    private func createGroup() {
        guard !groupName.isEmpty else {
            errorMessage = "Group name is required."
            showError = true
            return
        }
        isLoading = true
        showError = false
        errorMessage = ""
        Task {
            print("🟠 [CreateGroupView] Creating group: \(groupName)")
            await groupViewModel.createGroup(name: groupName, description: groupDescription)
            print("🟢 [CreateGroupView] Group creation attempted, now fetching user groups...")
            await groupViewModel.fetchUserGroups()
            await MainActor.run {
                isLoading = false
                // Check if there was an error
                if groupViewModel.errorMessage != nil {
                    errorMessage = groupViewModel.errorMessage ?? "Failed to create group. Please try again."
                    showError = true
                    print("🔴 [CreateGroupView] Error: \(errorMessage)")
                } else {
                    print("✅ [CreateGroupView] Group created and user groups refreshed. Dismissing view.")
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CreateGroupView(groupViewModel: GroupViewModel())
} 