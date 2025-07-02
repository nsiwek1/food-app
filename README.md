# 🍽️ GroupBite - macOS Restaurant Discovery App

GroupBite is a that helps groups of friends discover restaurants together through a Tinder-style swiping interface. Users can create groups, start restaurant discovery sessions, and find places everyone in the group likes.

## 🚀 What GroupBite Does Now

### ✅ **Fully Implemented Features**

#### 🔐 **User Authentication & Management**
- **Firebase Authentication**: Secure sign up, sign in, and sign out
- **User Profiles**: Display names, usernames, and profile information
- **Persistent Sessions**: Users stay logged in between app launches

#### 👥 **Group Management System**
- **Create Groups**: Build groups with custom names and descriptions
- **Join Groups**: Use 8-character invite codes to join existing groups
- **Group Details**: View members, group info, and manage group actions
- **Member Management**: See all group members with creator indicators
- **Leave Groups**: Users can leave groups they're no longer interested in
- **Real-time Updates**: Groups update instantly using Firebase Firestore

#### 📍 **Restaurant Discovery**
- **Google Places API Integration**: Fetches real restaurant data from Google
- **Restaurant Data**: Real photos, names, ratings, and details from Google Places

#### 🎯 **Interactive Restaurant Swiping**
- **Tinder-Style Interface**: Swipe right to like, left to pass on restaurants
- **Restaurant Cards**: Beautiful cards showing restaurant photos, names, and details
- **Swipe Gestures**: Smooth drag and drop interactions
- **Session Management**: Start discovery sessions with custom filters

#### ⚙️ **Session Configuration**
- **Custom Filters**: Set search radius, price levels, and restaurant types
- **Location-Based Search**: Automatically uses your current location
- **Multiple Cuisine Types**: Filter by restaurant, cafe, bar, pizza, sushi, and more
- **Price Controls**: Set budget preferences (1-4 price levels)

#### 🎨 **Modern macOS Design**
- **Native macOS UI**: Built specifically for macOS with proper window sizing
- **Responsive Layout**: Adapts to different window sizes
- **Modern Design System**: Consistent colors, typography, and spacing
- **Smooth Animations**: Fluid transitions and interactions

## 🛠️ Technical Architecture

### **Frontend**
- **SwiftUI**: Modern declarative UI framework

### **Backend & APIs**
- **Firebase Firestore**: Real-time database for groups and sessions
- **Firebase Authentication**: Secure user management
- **Google Places API**: Restaurant data and search functionality
- **Keychain Services**: Secure credential storage

### **App Structure**
```
GroupBite/
├── GroupBiteApp.swift              # Main app entry point
├── ContentView.swift               # Root view with authentication flow
├── Models/                         # Data models
│   ├── User.swift                 # User model
│   ├── Group.swift                # Group and GroupSession models
│   ├── Restaurant.swift           # Restaurant model
│   └── Swipe.swift                # Swipe model
├── ViewModels/                     # Business logic
│   ├── AuthViewModel.swift        # Authentication logic
│   ├── GroupViewModel.swift       # Group management logic
│   ├── GroupSessionViewModel.swift # Session management
│   └── RestaurantViewModel.swift  # Restaurant search logic
├── Views/                          # UI Components
│   ├── Authentication/            # Auth views
│   │   ├── AuthView.swift         # Combined sign in/up
│   ├── Group/                     # Group management views
│   │   ├── HomeView.swift         # Groups list and management
│   │   ├── CreateGroupView.swift  # Create new groups
│   │   └── GroupDetailView.swift  # Group details and actions
│   └── Restaurant/                # Restaurant discovery views
│       ├── SwipeView.swift        # Main swiping interface
│       ├── SessionFilterView.swift # Session configuration
│       ├── RestaurantCard.swift   # Restaurant card component
│       └── RestaurantDetailView.swift # Restaurant details popup
├── Managers/                       # System services
│   ├── LocationManager.swift      # Location services
│   └── APIConfig.swift            # API configuration
└── Design/                        # Design system
    ├── AppColors.swift            # Color palette
    ├── AppTypography.swift        # Typography system
    └── AppComponents.swift        # Reusable UI components
```

## 🔮 What's Next

The core restaurant discovery system is now complete! Future enhancements could include:

- **Push Notifications**: Alert users when matches are found
- **Restaurant Details**: Maps integration and detailed restaurant pages
- **Group Chat**: In-app messaging for group coordination
- **Match History**: View past matches and restaurant visits
- **Social Features**: Share matches on social media
- **Advanced Filters**: More detailed cuisine and preference options



**Ready to discover amazing restaurants with friends! 🍕🍔🍜** 