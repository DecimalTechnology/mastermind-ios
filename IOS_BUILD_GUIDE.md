# iOS Build Guide for Master Mind App

## ⚠️ Important Prerequisites

### 1. Hardware & Software Requirements
- **macOS computer** (iOS builds cannot be done on Windows/Linux)
- **Xcode** (latest version recommended)
  - Install from Mac App Store
  - After installation, run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
  - Accept license: `sudo xcodebuild -license accept`
- **CocoaPods** - Dependency manager for iOS
  ```bash
  sudo gem install cocoapods
  ```
- **Flutter** installed and configured

### 2. Apple Developer Account
- **Free account**: For testing on your own devices (7-day certificate)
- **Paid account ($99/year)**: Required for App Store distribution

### 3. Firebase Configuration (REQUIRED)
Your app uses Firebase, so you need to set it up:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create one)
3. Click "Add app" and select iOS
4. Register your app with bundle ID: `com.yourcompany.mastermind` (or your chosen ID)
5. Download `GoogleService-Info.plist`
6. **Place it in**: `ios/Runner/GoogleService-Info.plist`

## 📋 Step-by-Step Build Process

### Step 1: Configure Bundle Identifier
1. Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
2. Select "Runner" in the left panel
3. Under "General" tab, set:
   - **Display Name**: Oxygen Mastermind
   - **Bundle Identifier**: com.yourcompany.mastermind (must be unique)
   - **Version**: 1.0.0
   - **Build**: 1

### Step 2: Configure Signing
1. In Xcode, under "Signing & Capabilities":
2. Check "Automatically manage signing"
3. Select your Apple Developer Team
4. Xcode will automatically create provisioning profiles

### Step 3: Clean and Prepare
```bash
# Navigate to project directory
cd /path/to/Master-Mind

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Install iOS dependencies
cd ios
pod install
cd ..
```

### Step 4: Build Options

#### Option A: Build for Simulator (Testing)
```bash
flutter build ios --debug
```
Then open in Xcode and run on simulator.

#### Option B: Build for Physical Device (Testing)
1. Connect your iPhone/iPad via USB
2. Trust the computer on your device
3. In Xcode:
   - Select your device from the device dropdown
   - Click the "Play" button to build and run
   - First time: Go to Settings > General > VPN & Device Management > Trust developer

#### Option C: Build IPA for Ad-Hoc Distribution (Beta Testing)
```bash
flutter build ipa --release --export-method ad-hoc
```
- IPA file will be in: `build/ios/ipa/`
- Share via TestFlight or direct installation
- Requires devices to be registered in Developer Portal

#### Option D: Build IPA for App Store
```bash
flutter build ipa --release --export-method app-store
```
- IPA file will be in: `build/ios/ipa/`
- Upload to App Store Connect

### Step 5: Upload to App Store (Optional)

#### Method 1: Using Xcode
1. In Xcode: Product > Archive
2. Wait for archive to complete
3. Click "Distribute App"
4. Follow the wizard to upload to App Store Connect

#### Method 2: Using Transporter App
1. Download "Transporter" from Mac App Store
2. Drag and drop your .ipa file
3. Click "Deliver"

## 🔧 Quick Build Script

I've created a build script for you. On macOS, run:

```bash
# Make it executable
chmod +x build_ios.sh

# Run it
./build_ios.sh
```

## 🐛 Common Issues & Solutions

### Issue 1: CocoaPods Error
```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
```

### Issue 2: Signing Certificate Issues
- Go to Xcode > Preferences > Accounts
- Sign in with your Apple ID
- Download certificates
- Enable "Automatically manage signing" in project settings

### Issue 3: GoogleService-Info.plist Missing
- Download from Firebase Console
- Must be placed in `ios/Runner/` directory
- Clean and rebuild after adding

### Issue 4: Architecture Issues (M1/M2 Macs)
```bash
sudo arch -x86_64 gem install ffi
cd ios
arch -x86_64 pod install
cd ..
```

### Issue 5: Build Failed - "Command PhaseScriptExecution failed"
- Open Xcode
- Product > Clean Build Folder
- Close Xcode
- Run `flutter clean`
- Rebuild

## 📱 Testing Your Build

### Using Simulator
```bash
# List available simulators
flutter emulators

# Launch a simulator
flutter emulators --launch apple_ios_simulator

# Run app
flutter run
```

### Using Physical Device
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d [device-id]
```

## 🚀 Release Checklist

Before submitting to App Store:

- [ ] Firebase configured correctly
- [ ] All required permissions in Info.plist (✅ Already added)
- [ ] App icons generated (✅ Already configured)
- [ ] Bundle identifier is unique
- [ ] Version and build number updated
- [ ] Tested on real device
- [ ] All features working (camera, audio, Firebase, etc.)
- [ ] Privacy Policy URL ready (required for App Store)
- [ ] Screenshots prepared (various device sizes)
- [ ] App Store description written

## 📦 Build Output Locations

- **Debug Build**: `build/ios/Debug-iphoneos/Runner.app`
- **Release Build**: `build/ios/Release-iphoneos/Runner.app`
- **IPA File**: `build/ios/ipa/master_mind.ipa`
- **Archive**: Xcode Organizer > Archives

## 🔐 Code Signing Files

After first successful build, you'll have:
- Development certificate (for testing)
- Distribution certificate (for App Store)
- Provisioning profiles

These are managed by Xcode if "Automatically manage signing" is enabled.

## 📚 Additional Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [TestFlight Beta Testing](https://developer.apple.com/testflight/)

## ⚡ Quick Commands Reference

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Update iOS dependencies
cd ios && pod install && cd ..

# Build debug
flutter build ios --debug

# Build release
flutter build ios --release

# Build IPA for App Store
flutter build ipa --release --export-method app-store

# Run on device
flutter run --release

# Check Flutter doctor
flutter doctor -v
```

## 📞 Need Help?

If you encounter issues:
1. Check Flutter doctor: `flutter doctor -v`
2. Check Xcode logs in Xcode Organizer
3. Clean and rebuild
4. Check Firebase configuration
5. Verify bundle identifier is correct

---

**Note**: Since you're currently on Windows, you'll need access to a Mac to complete the iOS build. Consider using:
- A Mac computer
- MacStadium or similar Mac cloud services
- Codemagic, Bitrise, or other CI/CD services that support iOS builds

