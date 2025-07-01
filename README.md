# 🍽️ GroupBite - macOS Restaurant Discovery App

GroupBite is a **native macOS app** that helps groups of friends discover restaurants together through a Tinder-style swiping interface. Users can create groups, start restaurant discovery sessions, and find places everyone in the group likes.

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

#### 📍 **Location-Based Restaurant Discovery**
- **Real Location Services**: Uses your actual location to find nearby restaurants
- **Google Places API Integration**: Fetches real restaurant data from Google
- **Location Permissions**: Proper macOS location permission handling
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
- **Core Location**: Real location services for macOS
- **Combine**: Reactive programming for data flow

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

## 🚀 Getting Started

### Prerequisites
- **macOS 13.0 or later**
- **Xcode 15.0 or later**
- **Firebase account**
- **Google Places API key**

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd food-app
   ```

2. **Set up Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or select an existing one
   - Add a macOS app with bundle ID `com.groupbite.app`
   - Download the `GoogleService-Info.plist` file
   - Replace the placeholder file in `GroupBite/GoogleService-Info.plist`

3. **Configure Firebase Services**
   - Enable Authentication with Email/Password
   - Create a Firestore database
   - Set up Firestore security rules (see below)

4. **Set up Google Places API**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Places API
   - Create an API key
   - Add the key to `APIConfig.swift`

5. **Open in Xcode**
   ```bash
   open GroupBite.xcodeproj
   ```

6. **Build and Run**
   - Select your Mac as the target
   - Press `Cmd + R` to build and run

### Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Group members can read group data, creators can write
    match /groups/{groupId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.members;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // Group members can read/write session data
    match /groupSessions/{sessionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
    }
    
    // Group members can read/write swipes
    match /swipes/{swipeId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/groups/$(resource.data.groupId)).data.members;
    }
  }
}
```

## 🎯 How to Use GroupBite

### 1. **Get Started**
- Launch the app and sign up with your email
- Create a profile with your name and username

### 2. **Create or Join a Group**
- **Create a Group**: Set a name and description, get an invite code
- **Join a Group**: Use a friend's 8-character invite code

### 3. **Start Restaurant Discovery**
- Click on a group to see details
- Click "Start Session" to begin restaurant discovery
- Configure your preferences:
  - **Radius**: How far to search (up to 50km)
  - **Price Level**: Budget range (1-4)
  - **Restaurant Types**: Choose cuisines (restaurant, pizza, sushi, etc.)

### 4. **Swipe on Restaurants**
- **Swipe Right**: Like a restaurant
- **Swipe Left**: Pass on a restaurant
- **Tap Card**: View restaurant details
- **View Matches**: See restaurants everyone in your group liked

### 5. **Find Your Perfect Match**
- When everyone in the group has swiped on the same restaurant
- Get notified of matches
- View match details and make plans

## 🔧 Current Technical Features

### **Location Services**
- Real-time location detection using Core Location
- Automatic permission handling for macOS
- Fallback location services for different accuracy levels
- Location-based restaurant search within specified radius

### **Real Restaurant Data**
- Live data from Google Places API
- Restaurant photos, names, ratings, and details
- Price levels, cuisine types, and opening hours
- Real-time availability and information

### **Group Session Management**
- Real-time session state across all group members
- Synchronized swiping progress
- Match detection and notification
- Session history and results

### **Modern macOS Integration**
- Native window management and sizing
- Proper modal sheets and popovers
- macOS-specific UI patterns
- Responsive design for different screen sizes

## 🔮 What's Next

The core restaurant discovery system is now complete! Future enhancements could include:

- **Push Notifications**: Alert users when matches are found
- **Restaurant Details**: Maps integration and detailed restaurant pages
- **Group Chat**: In-app messaging for group coordination
- **Match History**: View past matches and restaurant visits
- **Social Features**: Share matches on social media
- **Advanced Filters**: More detailed cuisine and preference options

## 🐛 Known Issues & Solutions

### **Location Permission Issues**
- **Problem**: Location permission not requested on first launch
- **Solution**: Click "Request Location Permission" button in session filter
- **Alternative**: Enable manually in System Settings > Privacy & Security > Location Services

### **Firebase Bundle ID Mismatch**
- **Problem**: Bundle ID inconsistency warnings
- **Solution**: Ensure bundle ID in Xcode matches `com.groupbite.app`
- **Alternative**: Update `GoogleService-Info.plist` to match your bundle ID

### **Build Issues**
- **Problem**: Entitlements file modification errors
- **Solution**: Clean build folder (Cmd + Shift + K) and rebuild
- **Alternative**: Delete DerivedData folder and restart Xcode

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues:

1. Check the Xcode console for detailed error logs
2. Verify Firebase configuration in `GoogleService-Info.plist`
3. Ensure Google Places API key is properly configured
4. Check location permissions in System Settings
5. Clean and rebuild the project if experiencing build issues

---

**Ready to discover amazing restaurants with friends! 🍕🍔🍜** 