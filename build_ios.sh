#!/bin/bash

# iOS Build Script for Master Mind App
# Run this script on macOS with Xcode installed

echo "🚀 Starting iOS Build Process..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS builds can only be created on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed. Please install it from the App Store."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    exit 1
fi

# Check for GoogleService-Info.plist
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Warning: GoogleService-Info.plist not found in ios/Runner/"
    echo "   Firebase features may not work. Download it from Firebase Console."
    read -p "   Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📦 Cleaning previous builds..."
flutter clean

echo "📥 Getting dependencies..."
flutter pub get

echo "🔧 Installing iOS dependencies (CocoaPods)..."
cd ios
pod install --repo-update
cd ..

echo "🏗️  Building iOS app..."
echo ""
echo "Choose build type:"
echo "1) Debug build (for testing)"
echo "2) Release build (for distribution)"
echo "3) Build IPA for Ad-Hoc distribution"
echo "4) Build IPA for App Store"
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "Building debug version..."
        flutter build ios --debug
        ;;
    2)
        echo "Building release version..."
        flutter build ios --release
        ;;
    3)
        echo "Building IPA for Ad-Hoc distribution..."
        flutter build ipa --release --export-method ad-hoc
        echo "✅ IPA file created at: build/ios/ipa/"
        ;;
    4)
        echo "Building IPA for App Store..."
        flutter build ipa --release --export-method app-store
        echo "✅ IPA file created at: build/ios/ipa/"
        ;;
    *)
        echo "Invalid choice. Building debug version..."
        flutter build ios --debug
        ;;
esac

echo ""
echo "✅ Build completed!"
echo ""
echo "📱 Next steps:"
echo "   - For Simulator: Open ios/Runner.xcworkspace in Xcode and run"
echo "   - For Device: Archive in Xcode (Product > Archive)"
echo "   - For App Store: Upload IPA through App Store Connect or Transporter"

