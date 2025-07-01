# 🍽️ API Setup Guide for GroupBite

This guide will help you set up the Google Places API to enable real restaurant data in your GroupBite app.

## 🎯 What You'll Get

With the Google Places API properly configured, your app will have:
- ✅ Real restaurant data with names, addresses, and ratings
- ✅ Restaurant photos from Google
- ✅ Opening hours and current status
- ✅ Price levels and cuisine types
- ✅ Location-based search results

## 📋 Prerequisites

- A Google Cloud Platform account (free tier available)
- A Google Cloud project
- Billing enabled on your Google Cloud project (required for API usage)

## 🚀 Step-by-Step Setup

### Step 1: Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" at the top of the page
3. Click "New Project"
4. Enter a project name (e.g., "GroupBite App")
5. Click "Create"
6. Wait for the project to be created and select it

### Step 2: Enable Billing

1. In your Google Cloud project, go to [Billing](https://console.cloud.google.com/billing)
2. Click "Link a billing account"
3. Create a new billing account or link an existing one
4. **Note**: Google Places API has a generous free tier (1,000 requests/day)

### Step 3: Enable the Places API

1. Go to [APIs & Services > Library](https://console.cloud.google.com/apis/library)
2. Search for "Places API" (not "Places API New")
3. Click on "Places API" from the results
4. Click "Enable"

### Step 4: Create API Credentials

1. Go to [APIs & Services > Credentials](https://console.cloud.google.com/apis/credentials)
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key (you'll need this in the next step)

### Step 5: Configure API Key Restrictions (Highly Recommended)

1. Click on the API key you just created
2. Under "Application restrictions":
   - Select "iOS Apps" for iOS development
   - Add your app's bundle identifier (e.g., `com.groupbite.app`)
3. Under "API restrictions":
   - Select "Restrict key"
   - Select "Places API" from the list
4. Click "Save"

### Step 6: Update Your App Configuration

1. Open `GroupBite/GroupBite/Config/APIConfig.swift`
2. Replace the current API key with your actual API key:

```swift
static let googlePlacesAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
```

**Important**: Remove the test key `AIzaSyADflun5nTCsqSM7BXzwjVaCwR8LowaGL4` and replace it with your real API key.

### Step 7: Test the API

1. Build and run your app
2. Go to the "My Groups" screen
3. Tap the network icon in the toolbar to test the API
4. You should see a success message if everything is configured correctly

## 🔧 Troubleshooting

### ❌ "API Key test failed" Error

**Possible causes and solutions:**

1. **API Key Not Configured**
   - Make sure you've replaced the placeholder API key in `APIConfig.swift`
   - Verify the API key is not empty or the test key

2. **Places API Not Enabled**
   - Go to [APIs & Services > Library](https://console.cloud.google.com/apis/library)
   - Search for "Places API" and make sure it's enabled
   - **Important**: Enable "Places API" (not "Places API New")

3. **Billing Not Enabled**
   - Go to [Billing](https://console.cloud.google.com/billing)
   - Link a billing account to your project
   - Even with the free tier, billing must be enabled

4. **API Key Restrictions Too Strict**
   - Check your API key restrictions in [Credentials](https://console.cloud.google.com/apis/credentials)
   - Make sure the Places API is allowed
   - Verify iOS app restrictions match your bundle identifier

5. **Quota Exceeded**
   - Check your [API usage](https://console.cloud.google.com/apis/credentials)
   - The free tier includes 1,000 requests per day
   - Consider upgrading if you need more

### 🖼️ Images Not Loading

- Ensure your API key has access to the Places API
- Check that you're not exceeding your daily quota
- Verify the photo reference is valid

### 📍 Location Issues

- The app defaults to San Francisco if location services are not available
- Make sure location permissions are granted in your app
- Check that `NSLocationWhenInUseUsageDescription` is set in `Info.plist`

## 🔒 Security Best Practices

### 1. Never Commit API Keys to Version Control

**Option A: Use Environment Variables (Recommended)**

1. Create a `.env` file in your project root:
```
GOOGLE_PLACES_API_KEY=your_api_key_here
```

2. Update `APIConfig.swift`:
```swift
static let googlePlacesAPIKey: String = {
    guard let apiKey = ProcessInfo.processInfo.environment["GOOGLE_PLACES_API_KEY"] else {
        fatalError("Google Places API key not found in environment variables")
    }
    return apiKey
}()
```

3. Add `.env` to your `.gitignore` file:
```
# API Keys
.env
```

**Option B: Use Xcode Configuration**

1. Create a new configuration file `Config.xcconfig`:
```
GOOGLE_PLACES_API_KEY = your_api_key_here
```

2. Update `APIConfig.swift`:
```swift
static let googlePlacesAPIKey = Bundle.main.infoDictionary?["GOOGLE_PLACES_API_KEY"] as? String ?? ""
```

3. Add `Config.xcconfig` to your `.gitignore`

### 2. Restrict Your API Key

- Set application restrictions to limit which apps can use the key
- Set API restrictions to only allow the Places API
- Use IP restrictions for additional security (if applicable)

### 3. Monitor Usage

- Set up billing alerts in Google Cloud Console
- Regularly check your API usage
- Monitor for unusual activity

## 💰 API Usage and Billing

### Free Tier Limits
- **Nearby Search**: 1,000 requests per day
- **Place Photos**: 1,000 requests per day
- **Place Details**: 1,000 requests per day

### Paid Usage (after free tier)
- **Nearby Search**: $0.017 per 1,000 requests
- **Place Photos**: $0.007 per 1,000 requests
- **Place Details**: $0.017 per 1,000 requests

### Monitoring Usage
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "APIs & Services" > "Dashboard"
3. Click on "Places API"
4. View usage statistics and quotas

## 🧪 Testing Your Setup

### 1. Use the Built-in Test
- Tap the network icon in the app toolbar
- Check the console output for detailed information
- Look for success/error messages

### 2. Manual API Test
You can test your API key directly in a browser:
```
https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.7749,-122.4194&radius=1000&type=restaurant&key=YOUR_API_KEY
```

### 3. Check Console Output
When testing, check Xcode's console for detailed error messages and API responses.

## 📱 App Integration

Once your API is working:

1. **Create a group** in the app
2. **Start a restaurant search** - you should see real restaurant data
3. **View restaurant details** - photos, ratings, and information should load
4. **Test location-based search** - restaurants should appear near your location

## 🆘 Getting Help

If you're still having issues:

1. **Check the console output** in Xcode for detailed error messages
2. **Verify your Google Cloud Console** settings
3. **Test your API key** using the manual URL above
4. **Check the [Google Places API documentation](https://developers.google.com/maps/documentation/places/web-service)**
5. **Review your billing and quota usage**

## 🎉 Success!

Once everything is working, you should see:
- ✅ Real restaurant names and addresses
- ✅ Restaurant photos loading properly
- ✅ Ratings and price levels
- ✅ Location-based search results
- ✅ No more "API Key test failed" messages

Your GroupBite app is now ready to help groups find amazing restaurants together! 🍕🍜🍔 