# 🔐 How to Make LearnMorseCode Appear in System Settings

## The Problem
Your app is not appearing in macOS System Settings because it's not properly signed with a developer certificate. Apps need proper code signing to be recognized by macOS privacy controls.

## ✅ Solution: Use Xcode with Developer Account

### Step 1: Get a Free Apple Developer Account
1. Go to https://developer.apple.com
2. Click "Account" → "Sign In"
3. Use your Apple ID to sign in
4. Accept the developer agreement (it's free for personal use)

### Step 2: Open Project in Xcode
```bash
open LearnMorseCode.xcodeproj
```

### Step 3: Set Up Code Signing
1. In Xcode, select the **LearnMorseCode** project (top item in the navigator)
2. Select the **LearnMorseCode** target
3. Go to the **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"**
5. In the **"Team"** dropdown, select your Apple ID/Developer Team
6. Xcode will automatically create a development certificate

### Step 4: Build and Run from Xcode
1. Press **Cmd+R** or click the **Play** button
2. Xcode will build and run the app with proper signing
3. The app will now appear in System Settings!

### Step 5: Test Permissions
1. Go to **System Settings** → **Privacy & Security** → **Microphone**
2. You should now see **LearnMorseCode** in the list
3. Toggle it **ON** to grant microphone access
4. Go to **System Settings** → **Privacy & Security** → **Speech Recognition**
5. You should see **LearnMorseCode** there too - toggle it **ON**

## 🎯 What This Fixes
- ✅ App appears in System Settings → Privacy & Security → Microphone
- ✅ App appears in System Settings → Privacy & Security → Speech Recognition
- ✅ Users can grant/revoke permissions through the system UI
- ✅ Proper permission dialogs show when the app requests access
- ✅ Voice to Morse feature will work properly

## 🚀 Alternative: Quick Test (Temporary)
If you want to test the Voice to Morse feature immediately without setting up Xcode:

1. **Run the app**: `./build_and_run.sh`
2. **Try the Voice to Morse feature**
3. **When prompted for permissions, click "Allow"**
4. The app should work, but it won't appear in System Settings

## 📝 Notes
- The Xcode method is the **proper long-term solution**
- Once set up, the app will always appear in System Settings
- You can distribute the app to others and it will work properly
- The quick test method only works temporarily

## 🔧 Troubleshooting
If you still don't see the app in System Settings after following these steps:
1. Make sure you're using the **same Apple ID** in Xcode that you used for the developer account
2. Try **cleaning the build folder** in Xcode (Product → Clean Build Folder)
3. **Restart your Mac** after setting up code signing
4. Check that the app is properly signed by running: `codesign -dv --verbose=4 DerivedData/Build/Products/Debug/LearnMorseCode.app`
