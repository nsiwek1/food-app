import SwiftUI

// MARK: - Color Palette
struct AppColors {
    // Primary Colors
    static let primary = Color(red: 1.0, green: 0.42, blue: 0.21) // #FF6B35 - Deep Orange
    static let primaryLight = Color(red: 1.0, green: 0.6, blue: 0.4) // #FF9966
    static let primaryDark = Color(red: 0.8, green: 0.34, blue: 0.17) // #CC562B
    
    // Secondary Colors
    static let secondary = Color(red: 0.31, green: 0.8, blue: 0.77) // #4ECDC4 - Teal
    static let secondaryLight = Color(red: 0.6, green: 0.9, blue: 0.88) // #99E6E0
    static let secondaryDark = Color(red: 0.25, green: 0.64, blue: 0.62) // #40A4A0
    
    // Accent Colors
    static let accent = Color(red: 1.0, green: 0.9, blue: 0.43) // #FFE66D - Warm Yellow
    static let accentLight = Color(red: 1.0, green: 0.95, blue: 0.6) // #FFF299
    
    // Neutral Colors
    static let background = Color(red: 0.97, green: 0.97, blue: 0.97) // #F7F7F7
    static let surface = Color.white
    static let surfaceSecondary = Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
    static let border = Color(red: 0.88, green: 0.88, blue: 0.88) // #E0E0E0
    
    // Text Colors
    static let textPrimary = Color(red: 0.13, green: 0.13, blue: 0.13) // #212121
    static let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.45) // #737373
    static let textTertiary = Color(red: 0.62, green: 0.62, blue: 0.62) // #9E9E9E
    
    // Status Colors
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66
    static let warning = Color(red: 1.0, green: 0.65, blue: 0.0) // #FFA500
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // #E64D4D
    static let info = Color(red: 0.2, green: 0.6, blue: 1.0) // #3399FF
    
    // Swipe Colors
    static let like = Color(red: 0.2, green: 0.8, blue: 0.4) // #33CC66
    static let dislike = Color(red: 0.9, green: 0.3, blue: 0.3) // #E64D4D
}

// MARK: - Typography
struct AppTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .medium, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .medium, design: .rounded)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Shadows
struct AppShadows {
    static let small = Shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    static let large = Shadow(color: .black.opacity(0.2), radius: 16, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - Reusable Components
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    
    init(_ title: String, icon: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: AppColors.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(AppTypography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
            .cornerRadius(AppCornerRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    init(_ icon: String, color: Color = AppColors.primary, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(AppColors.surface)
                .cornerRadius(AppCornerRadius.full)
                .shadow(color: color.opacity(0.2), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadow: Shadow
    
    init(padding: CGFloat = AppSpacing.lg, 
         cornerRadius: CGFloat = AppCornerRadius.lg,
         shadow: Shadow = AppShadows.medium,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(AppColors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

struct BadgeView: View {
    let text: String
    let color: Color
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium:
                return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .large:
                return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return AppTypography.caption2
            case .medium:
                return AppTypography.caption1
            case .large:
                return AppTypography.footnote
            }
        }
    }
    
    init(_ text: String, color: Color = AppColors.primary, size: BadgeSize = .medium) {
        self.text = text
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(size.padding)
            .background(color.opacity(0.1))
            .cornerRadius(AppCornerRadius.full)
    }
}

struct AvatarView: View {
    let initials: String
    let size: CGFloat
    let color: Color
    
    init(_ initials: String, size: CGFloat = 40, color: Color = AppColors.primary) {
        self.initials = initials
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.full)
            .shadow(color: color.opacity(0.3), radius: 4, y: 2)
    }
}

// MARK: - Extensions
extension View {
    func cardStyle(padding: CGFloat = AppSpacing.lg, 
                   cornerRadius: CGFloat = AppCornerRadius.lg,
                   shadow: Shadow = AppShadows.medium) -> some View {
        self
            .padding(padding)
            .background(AppColors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func primaryTextStyle() -> some View {
        self
            .font(AppTypography.body)
            .foregroundColor(AppColors.textPrimary)
    }
    
    func secondaryTextStyle() -> some View {
        self
            .font(AppTypography.subheadline)
            .foregroundColor(AppColors.textSecondary)
    }
    
    func captionTextStyle() -> some View {
        self
            .font(AppTypography.caption1)
            .foregroundColor(AppColors.textTertiary)
    }
} 