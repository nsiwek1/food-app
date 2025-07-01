import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            headerView
            Divider().background(AppColors.border)
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Restaurant Image
                    if let photoReference = restaurant.photoReference {
                        AsyncImage(url: APIConfig.photoURL(photoReference: photoReference)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(AppColors.surface)
                                .frame(height: 250)
                                .overlay(
                                    VStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "fork.knife.circle")
                                            .font(.system(size: 50, weight: .light))
                                            .foregroundColor(AppColors.textTertiary)
                                        Text("No Image Available")
                                            .font(AppTypography.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                )
                        }
                        .cornerRadius(AppCornerRadius.lg)
                    }
                    
                    // Basic Info
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(restaurant.name)
                            .font(AppTypography.title1)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(restaurant.address)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    // Rating and Price
                    HStack {
                        if let rating = restaurant.rating {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppColors.accent)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(String(format: "%.1f", rating))
                                    .font(AppTypography.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                if let userRatingsTotal = restaurant.userRatingsTotal {
                                    Text("(\(userRatingsTotal) reviews)")
                                        .font(AppTypography.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if let priceLevel = restaurant.priceLevel {
                            Text(String(repeating: "$", count: priceLevel))
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
                    
                    // Types
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Cuisine Types")
                            .font(AppTypography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.sm) {
                            ForEach(restaurant.types, id: \.self) { type in
                                Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(AppTypography.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(AppColors.primary.opacity(0.1))
                                    .foregroundColor(AppColors.primary)
                                    .cornerRadius(AppCornerRadius.md)
                            }
                        }
                    }
                    
                    // Additional Info
                    if let phoneNumber = restaurant.phoneNumber {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Phone")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            Text(phoneNumber)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if let website = restaurant.website {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Website")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            Link(website, destination: URL(string: website) ?? URL(string: "https://example.com")!)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    
                    // Opening Hours
                    if let openingHours = restaurant.openingHours, !openingHours.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Opening Hours")
                                .font(AppTypography.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                ForEach(openingHours, id: \.self) { day in
                                    Text(day)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // Place ID (for debugging)
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Place ID")
                            .font(AppTypography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textTertiary)
                        Text(restaurant.placeId)
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textTertiary)
                            .textSelection(.enabled)
                    }
                }
                .padding(AppSpacing.lg)
            }
        }
        .frame(minWidth: 500, minHeight: 700)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
    
    private var headerView: some View {
        HStack {
            Text("Restaurant Details")
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
} 