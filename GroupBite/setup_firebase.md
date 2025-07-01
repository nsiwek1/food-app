# 🔥 Firebase Setup Fix Guide

## 🚨 Current Issue: "Missing or Insufficient Addresses"

Your Firebase project exists but the **Firestore database hasn't been created yet**. This is causing the "missing or insufficient addresses" error.

## 🛠️ Step-by-Step Fix

### Step 1: Create Firestore Database

1. **Open Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `food-app-8a47a`
3. **Go to Firestore Database**:
   - Click "Firestore Database" in the left sidebar
   - Click "Create database"
4. **Choose security mode**:
   - Select **"Start in test mode"** (for development)
   - Click "Next"
5. **Choose location**:
   - Select `us-central1` (or closest to you)
   - Click "Done"

### Step 2: Enable Authentication

1. **Go to Authentication**:
   - Click "Authentication" in the left sidebar
   - Click "Get started"
2. **Enable Email/Password**:
   - Click "Sign-in method" tab
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"

### Step 3: Set Up Security Rules

1. **Go to Firestore Database** → **Rules**
2. **Replace the rules with**:

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
    
    // Test collection for connection testing
    match /test/{document} {
      allow read, write: if true;
    }
  }
}
```

3. **Click "Publish"**

### Step 4: Test the Connection

After completing the above steps:

1. **Quit the app completely**
2. **Restart the app**
3. **Try signing up again**

## 🔍 Verification Steps

### Check if Database is Created:
- Go to Firestore Database in Firebase Console
- You should see "Cloud Firestore" with a database listed
- Status should be "Active"

### Check Authentication:
- Go to Authentication → Users
- Should show "No users yet" (normal for new setup)

### Check Security Rules:
- Go to Firestore Database → Rules
- Should show the rules you pasted above

## 🚨 If Still Having Issues

### Clear App Data:
```bash
# In Terminal, run:
rm -rf ~/Library/Containers/com.groupbite.GroupBite/Data/Library/Application\ Support/firestore/
```

### Check Network:
- Ensure your Mac has internet connection
- Try disabling VPN if you're using one
- Check if firewall is blocking Firebase connections

### Alternative: Use Mock Mode Temporarily
If Firebase setup takes time, you can use the app in mock mode:
- The app will automatically switch to mock mode if Firebase fails
- You can still test all features with mock data
- Switch back to real Firebase once setup is complete

## 📞 Need Help?

If you're still having issues:
1. Check Firebase Console for any error messages
2. Verify your `GoogleService-Info.plist` is in the correct location
3. Make sure you're using the latest version of the app
4. Try creating a new Firebase project if needed

---

**After completing these steps, your app should work with real Firebase data! 🎉** 