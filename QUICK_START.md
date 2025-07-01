# ⚡ Quick Start Guide

## Get GroupBite Running in 5 Minutes!

### 🚀 Step 1: Open in Xcode
```bash
# Navigate to your project
cd /Users/natalia_mac/Desktop/food-app

# Open the project in Xcode
open GroupBite.xcodeproj
```

### 🔥 Step 2: Set Up Firebase (Required)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create New Project** (or use existing)
3. **Add iOS App**:
   - Bundle ID: `com.groupbite.app`
   - App nickname: `GroupBite`
4. **Download Config File**:
   - Download `GoogleService-Info.plist`
   - Replace the placeholder file in `GroupBite/GoogleService-Info.plist`

### ⚙️ Step 3: Enable Firebase Services

In Firebase Console:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in test mode
   - Set up security rules (see below)

### 🔒 Step 4: Security Rules

In Firestore → Rules, paste:

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
    
    // Allow group creation
    match /groups/{groupId} {
      allow create: if request.auth != null;
    }
  }
}
```

### 📱 Step 5: Build & Run

1. **Select Target**: Choose iPhone simulator or device
2. **Build**: Press `Cmd + R`
3. **Test**: App launches with Sign In screen!

---

## 🧪 Test the App

### Create Your First Group:

1. **Sign Up**:
   - Tap "Sign Up"
   - Fill: Name, Username, Email, Password
   - Tap "Create Account"

2. **Create Group**:
   - Tap "Create Group"
   - Name: "Test Group"
   - Description: "My first group"
   - Tap "Create Group"

3. **View Group**:
   - Tap on your group
   - See group details
   - Copy invite code

4. **Test Invite**:
   - Share invite code with friend
   - Have them join the group
   - Watch real-time updates!

---

## 🎯 Demo Features to Try

### ✅ **Authentication**
- [ ] Sign up with new account
- [ ] Sign in with existing account
- [ ] Sign out and back in

### ✅ **Group Management**
- [ ] Create a new group
- [ ] View group details
- [ ] Copy invite code
- [ ] Join group with invite code
- [ ] View group members
- [ ] Leave group

### ✅ **Real-time Features**
- [ ] Create group on one device
- [ ] Join on another device
- [ ] Watch member count update
- [ ] See real-time member list

### ✅ **Error Handling**
- [ ] Try invalid invite code
- [ ] Try joining same group twice
- [ ] Test with no internet connection

---

## 🔧 Troubleshooting

### ❌ Build Errors
- **Missing Firebase**: Make sure `GoogleService-Info.plist` is replaced
- **Package Dependencies**: Clean build folder (`Cmd + Shift + K`)
- **iOS Version**: Ensure target is iOS 17.0+

### ❌ Runtime Errors
- **Firebase Not Configured**: Check `GoogleService-Info.plist`
- **Authentication Fails**: Verify Firebase Auth is enabled
- **Database Errors**: Check Firestore security rules

### ❌ Network Issues
- **No Internet**: App shows appropriate error messages
- **Firebase Down**: Check Firebase Console status

---

## 📱 Simulator vs Device

### iPhone Simulator
- ✅ Faster testing
- ✅ No device setup required
- ✅ Multiple device sizes
- ❌ No real push notifications

### Physical Device
- ✅ Full feature testing
- ✅ Real network conditions
- ✅ Push notifications (when implemented)
- ❌ Requires device setup

---

## 🎬 Demo Tips

### For Presentations:
1. **Prepare Test Data**: Create groups beforehand
2. **Multiple Devices**: Use simulator + device for real-time demo
3. **Invite Codes**: Have codes ready to share
4. **Error Scenarios**: Plan to show error handling

### For Testing:
1. **Clean State**: Delete app between tests
2. **Multiple Users**: Create different accounts
3. **Edge Cases**: Test invalid inputs
4. **Network**: Test offline scenarios

---

## 🚀 Ready to Go!

Your GroupBite app is now fully functional with:
- ✅ User authentication
- ✅ Group creation and management
- ✅ Real-time updates
- ✅ Invite system
- ✅ Modern UI/UX

**Next up**: Restaurant search and swiping features! 🍽️

---

**Need help?** Check the main README.md for detailed setup instructions. 