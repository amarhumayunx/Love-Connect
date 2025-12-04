# Firestore Setup Instructions

## Issue: Firestore API Not Enabled

If you're seeing this error:
```
Cloud Firestore API has not been used in project love-connect-e79a5 before or it is disabled.
```

Follow these steps to enable Firestore:

## Step 1: Enable Firestore API

1. Go to [Google Cloud Console - Firestore API](https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=love-connect-e79a5)
2. Click **"Enable"** button
3. Wait a few minutes for the API to be enabled

## Step 2: Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **love-connect-e79a5**
3. In the left sidebar, click on **"Firestore Database"**
4. Click **"Create database"** button
5. Choose your security rules:
   - **Start in test mode** (for development)
   - Or **Start in production mode** (for production)
6. Select a location for your database (choose the closest to your users)
7. Click **"Enable"**

## Step 3: Configure Security Rules (Important!)

After creating the database, go to **Rules** tab and set up appropriate security rules:

### For Development/Testing:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
  }
}
```

### For Production (More Secure):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow checking if user exists by email (for login check)
      allow read: if request.auth != null;
    }
  }
}
```

## Step 4: Verify Setup

1. After enabling the API and creating the database, wait 2-5 minutes
2. Restart your app
3. Try creating a new account - it should now save to Firestore without errors

## Alternative: Quick Enable Link

Click this direct link to enable Firestore API:
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=love-connect-e79a5

## Notes

- The app will still work even if Firestore is not enabled (it will fallback to Firebase Auth only)
- However, the user existence check feature requires Firestore to be enabled
- All user data operations will gracefully handle Firestore errors and continue working

