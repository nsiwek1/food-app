import SwiftUI
import CoreLocation

struct SwipeView: View {
    let group: Group
    @StateObject private var sessionViewModel = GroupSessionViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var showingSessionFilter = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            if sessionViewModel.isLoading {
                loadingView
            } else if let session = sessionViewModel.currentSession {
                if session.restaurants.isEmpty {
                    emptyStateView
                } else {
                    swipeCardsView(session: session)
                }
            } else {
                setupSessionView
            }
        }
        .frame(minWidth: 700, minHeight: 900)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .sheet(isPresented: $showingSessionFilter) {
            SessionFilterView(sessionViewModel: sessionViewModel, locationManager: locationManager, groupId: group.id ?? "")
        }
        .onAppear {
            print("📍 SwipeView: onAppear - requesting location")
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                print("📍 SwipeView: Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
    }
    
    private func setupLocation() {
        print("📍 SwipeView: Setting up location...")
        locationManager.requestLocation()
        
        // Monitor location changes
        if let location = locationManager.location {
            print("📍 SwipeView: Location available: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            if let session = sessionViewModel.currentSession {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Group Session")
                            .font(AppTypography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("\(session.restaurants.count) restaurants • Session ID: \(session.id ?? "Unknown")")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showingSessionFilter = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Filters")
                                .font(AppTypography.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppColors.primary)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppCornerRadius.md)
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppColors.surface)
                .overlay(
                    Rectangle()
                        .fill(AppColors.border)
                        .frame(height: 1),
                    alignment: .bottom
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
                .foregroundColor(AppColors.primary)
            
            Text("Loading restaurants...")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(AppColors.textTertiary)
                
                VStack(spacing: AppSpacing.md) {
                    Text("No More Restaurants")
                        .font(AppTypography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("You've seen all the restaurants in your area. Try adjusting your filters or expanding your search radius.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                PrimaryButton("Adjust Filters", icon: "slider.horizontal.3") {
                    showingSessionFilter = true
                }
                .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
        }
    }
    
    private var setupSessionView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(AppColors.primary)
                
                VStack(spacing: AppSpacing.md) {
                    Text("Start Swiping Session")
                        .font(AppTypography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Configure your preferences and start discovering restaurants with your group.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                PrimaryButton("Start Session", icon: "play.fill") {
                    showingSessionFilter = true
                }
                .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
        }
    }
    
    private func swipeCardsView(session: GroupSession) -> some View {
        ZStack {
            ForEach(Array(session.restaurants.enumerated()), id: \.element.id) { index, restaurant in
                if index >= currentIndex && index < currentIndex + 3 {
                    RestaurantCard(
                        restaurant: restaurant,
                        isTopCard: index == currentIndex,
                        dragOffset: $dragOffset
                    ) { action in
                        handleSwipe(restaurant: restaurant, action: action)
                    }
                    .offset(x: index == currentIndex ? dragOffset.width : 0,
                           y: index == currentIndex ? dragOffset.height : 0)
                    .scaleEffect(index == currentIndex ? 1.0 : 0.95)
                    .opacity(index == currentIndex ? 1.0 : 0.8)
                    .zIndex(Double(session.restaurants.count - index))
                }
            }
        }
        .padding(AppSpacing.lg)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if currentIndex < session.restaurants.count {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if currentIndex < session.restaurants.count {
                        let threshold: CGFloat = 100
                        if abs(value.translation.width) > threshold {
                            if value.translation.width > 0 {
                                handleSwipe(restaurant: session.restaurants[currentIndex], action: .like)
                            } else {
                                handleSwipe(restaurant: session.restaurants[currentIndex], action: .dislike)
                            }
                        }
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
    
    private func handleSwipe(restaurant: Restaurant, action: SwipeAction) {
        // Handle the swipe action
        print("Swiped \(action) on \(restaurant.name)")
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
        }
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    let isTopCard: Bool
    @Binding var dragOffset: CGSize
    let onSwipe: (SwipeAction) -> Void
    
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Image - Fixed height
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                
                if let photoRef = restaurant.photoReference {
                    AsyncImage(url: APIConfig.photoURL(photoReference: photoRef)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                                .foregroundColor(AppColors.textSecondary)
                            Text("Loading...")
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                } else {
                    VStack {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(AppColors.textTertiary)
                        Text("No Image")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Rating overlay
                if let rating = restaurant.rating {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppColors.accent)
                                Text(String(format: "%.1f", rating))
                                    .font(AppTypography.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(AppSpacing.xs)
                            .background(AppColors.accent)
                            .cornerRadius(AppCornerRadius.sm)
                        }
                        Spacer()
                    }
                    .padding(AppSpacing.sm)
                }
            }
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Name and Price
                HStack {
                    Text(restaurant.name)
                        .font(AppTypography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let priceLevel = restaurant.priceLevel {
                        Text(String(repeating: "$", count: priceLevel))
                            .font(AppTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // Address
                Text(restaurant.address)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                
                // Restaurant Types
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(restaurant.types.prefix(4), id: \.self) { type in
                            BadgeView(
                                type.replacingOccurrences(of: "_", with: " ").capitalized,
                                color: AppColors.primary,
                                size: .small
                            )
                        }
                    }
                }
                .frame(height: 30)
                
                // Action Buttons - Fixed height
                HStack(spacing: AppSpacing.lg) {
                    IconButton("xmark.circle.fill", color: AppColors.dislike, size: 50) {
                        onSwipe(.dislike)
                    }
                    
                    IconButton("info.circle.fill", color: AppColors.info, size: 50) {
                        showingDetails = true
                    }
                    
                    IconButton("heart.circle.fill", color: AppColors.like, size: 50) {
                        onSwipe(.like)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(AppColors.surface)
        .cornerRadius(AppCornerRadius.lg)
        .shadow(color: AppShadows.large.color, radius: AppShadows.large.radius, x: AppShadows.large.x, y: AppShadows.large.y)
        .frame(width: 400, height: 450)
        .sheet(isPresented: $showingDetails) {
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}

enum SwipeAction {
    case like, dislike
}

#Preview {
    SwipeView(group: Group(name: "Group 1", description: "Test group", createdBy: "user1"))
} 