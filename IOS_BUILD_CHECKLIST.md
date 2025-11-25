# iOS Build Checklist

## ✅ What I've Done For You

- [x] Added required iOS permissions to `Info.plist`:
  - Camera access
  - Photo library access
  - Microphone access
  - Photo library add access
- [x] Created `Podfile` for iOS dependencies
- [x] Created `build_ios.sh` script for easy building
- [x] Created comprehensive build guide (`IOS_BUILD_GUIDE.md`)

## 🚨 What YOU Need to Do

### Before Building (CRITICAL)

1. **Get a Mac Computer** ⚠️
   - You're currently on Windows
   - iOS builds ONLY work on macOS
   - Options:
     - Use your own Mac
     - Borrow a Mac
     - Use cloud Mac service (MacStadium, MacinCloud)
     - Use CI/CD service (Codemagic, Bitrise)

2. **Install Xcode** (on Mac)
   ```bash
   # Install from Mac App Store, then:
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   ```

3. **Install CocoaPods** (on Mac)
   ```bash
   sudo gem install cocoapods
   ```

4. **Configure Firebase for iOS** ⚠️ REQUIRED
   - [ ] Go to [Firebase Console](https://console.firebase.google.com/)
   - [ ] Select your project
   - [ ] Add iOS app
   - [ ] Download `GoogleService-Info.plist`
   - [ ] Place it in: `ios/Runner/GoogleService-Info.plist`
   - [ ] **Without this, your app will crash on launch!**

### On the Mac

5. **Transfer Project to Mac**
   - [ ] Copy entire project folder to Mac
   - [ ] Or use Git to clone

6. **Run Flutter Doctor**
   ```bash
   flutter doctor -v
   ```
   Make sure all checks pass (especially Xcode and CocoaPods)

7. **Configure Bundle Identifier**
   - [ ] Open `ios/Runner.xcworkspace` in Xcode
   - [ ] Select Runner > General
   - [ ] Set a unique Bundle Identifier (e.g., `com.yourcompany.mastermind`)
   - [ ] This must match your Firebase iOS app bundle ID

8. **Configure Code Signing**
   - [ ] In Xcode, go to "Signing & Capabilities"
   - [ ] Check "Automatically manage signing"
   - [ ] Select your Team (Apple Developer Account)

9. **Install Dependencies**
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

10. **Choose Build Type and Build**

    **For Testing on Simulator:**
    ```bash
    flutter build ios --debug
    # Then open Xcode and run on simulator
    ```

    **For Testing on Physical Device:**
    ```bash
    flutter run --release
    # Device must be connected and trusted
    ```

    **For App Store:**
    ```bash
    flutter build ipa --release --export-method app-store
    # IPA will be in build/ios/ipa/
    ```

## 📋 Pre-Submission Checklist (App Store)

- [ ] App tested on real device
- [ ] All features working:
  - [ ] Camera
  - [ ] Photo library
  - [ ] Audio recording
  - [ ] Firebase auth
  - [ ] Firebase storage
  - [ ] QR scanner
  - [ ] All screens loading correctly
- [ ] No crash on launch
- [ ] Privacy Policy URL ready
- [ ] App screenshots prepared (5.5", 6.5", 12.9")
- [ ] App description written
- [ ] Keywords selected
- [ ] App Store icon (1024x1024)
- [ ] Version number set correctly

## 🔗 Quick Links

- [Firebase Console](https://console.firebase.google.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Apple Developer Portal](https://developer.apple.com/account)
- [Detailed Build Guide](./IOS_BUILD_GUIDE.md)

## 🆘 Troubleshooting

**Error: Command PhaseScriptExecution failed**
```bash
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

**Error: No valid code signing**
- Enable "Automatically manage signing" in Xcode
- Make sure you're signed in with Apple ID in Xcode Preferences

**Error: GoogleService-Info.plist not found**
- Download from Firebase Console
- Place in `ios/Runner/` directory
- Clean and rebuild

## ⏱️ Estimated Time

- Setup (first time): 1-2 hours
- Build (subsequent): 10-15 minutes
- App Store review: 1-3 days

## 🎯 Quick Start (on Mac)

```bash
# 1. Make build script executable
chmod +x build_ios.sh

# 2. Run it
./build_ios.sh

# 3. Follow the prompts
```

---

**Current Status**: ✅ Project configured for iOS build  
**Next Step**: Transfer to Mac and add Firebase config

