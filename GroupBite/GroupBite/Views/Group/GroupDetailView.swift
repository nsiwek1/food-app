import SwiftUI
import FirebaseFirestore

struct GroupDetailView: View {
    let group: Group
    @StateObject private var groupViewModel = GroupViewModel()
    @State private var showingInviteSheet = false
    @State private var showingLeaveAlert = false
    @State private var groupMembers: [User] = []
    @State private var isLoadingMembers = false
    @State private var showingRestaurantSearch = false
    @State private var showingSwipeView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            headerView
            Divider().background(AppColors.border)
            
            // Content
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Group Info Card
                    groupInfoCard
                    
                    // Members Section
                    membersSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(AppSpacing.lg)
            }
        }
        .frame(minWidth: 400, minHeight: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .sheet(isPresented: $showingSwipeView) {
            SwipeView(group: group)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Invite") {
                    showingInviteSheet = true
                }
                .foregroundColor(.orange)
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
            InviteSheet(group: group)
        }
        .alert("Leave Group", isPresented: $showingLeaveAlert) {
            Button("Leave", role: .destructive) {
                leaveGroup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this group? You won't be able to rejoin without an invite code.")
        }
        .onAppear {
            fetchGroupMembers()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text(group.name)
                .font(AppTypography.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            PrimaryButton("Start Session", icon: "play.fill") {
                showingSwipeView = true
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
    }
    
    private var groupInfoCard: some View {
        CardView(padding: AppSpacing.lg, shadow: AppShadows.small) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Group Information")
                        .font(AppTypography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                VStack(spacing: AppSpacing.md) {
                    InfoRow(
                        icon: "calendar",
                        title: "Created",
                        value: group.createdAt.formatted(date: .abbreviated, time: .omitted)
                    )
                    
                    InfoRow(
                        icon: "key.fill",
                        title: "Invite Code",
                        value: group.inviteCode,
                        isCode: true
                    )
                    
                    InfoRow(
                        icon: "person.fill",
                        title: "Created by",
                        value: group.createdBy
                    )
                }
            }
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Members")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                BadgeView("\(group.members.count)", color: AppColors.primary, size: .medium)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) {
                ForEach(group.members, id: \.self) { member in
                    MemberCard(member: member)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryButton("Start Restaurant Session", icon: "play.fill") {
                showingSwipeView = true
            }
            
            SecondaryButton("Share Invite Code", icon: "square.and.arrow.up") {
                shareInviteCode()
            }
        }
    }
    
    private func fetchGroupMembers() {
        isLoadingMembers = true
        
        let db = Firestore.firestore()
        
        Task {
            do {
                var members: [User] = []
                
                for memberId in group.members {
                    let document = try await db.collection("users").document(memberId).getDocument()
                    if let user = try? document.data(as: User.self) {
                        members.append(user)
                    }
                }
                
                await MainActor.run {
                    self.groupMembers = members
                    self.isLoadingMembers = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMembers = false
                }
            }
        }
    }
    
    private func leaveGroup() {
        Task {
            await groupViewModel.leaveGroup(groupId: group.id ?? "")
        }
    }
    
    private func shareInviteCode() {
        let inviteText = "Join my group '\(group.name)' on GroupBite! Use invite code: \(group.inviteCode)"
        
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(inviteText, forType: .string)
        #endif
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let isCode: Bool
    
    init(icon: String, title: String, value: String, isCode: Bool = false) {
        self.icon = icon
        self.title = title
        self.value = value
        self.isCode = false
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            if isCode {
                Button(action: {
                    #if os(macOS)
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(value, forType: .string)
                    #endif
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfaceSecondary)
        .cornerRadius(AppCornerRadius.md)
    }
}

struct MemberCard: View {
    let member: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AvatarView(member.prefix(2).uppercased(), size: 40, color: AppColors.secondary)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(member)
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text("Member")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

struct InviteSheet: View {
    let group: Group
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Invite Friends")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Share this invite code with your friends")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Text("Invite Code")
                        .font(.headline)
                    
                    Text(group.inviteCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        #if os(iOS)
                        UIPasteboard.general.string = group.inviteCode
                        #elseif os(macOS)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(group.inviteCode, forType: .string)
                        #endif
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Code")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // TODO: Share via system share sheet
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Invite Friends")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GroupDetailView(group: Group(
        name: "Test Group",
        description: "A test group for finding restaurants",
        createdBy: "user1"
    ))
} 