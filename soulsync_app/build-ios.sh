#!/bin/bash
# SoulSync iOS Build & Validation Script
# Run this before submitting to App Store to ensure everything is correct

set -e  # Exit on error

echo "======================================"
echo "🚀 SoulSync iOS Build & Validation"
echo "======================================"
echo ""

# Step 1: Check current directory
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: Not in Flutter project root. Please cd to:"
  echo "   /Users/vikashvardhan/Downloads/soulsync-frontend/soulsync_app"
  exit 1
fi

echo "✅ Flutter project detected"
echo ""

# Step 2: Flutter Doctor
echo "📋 Step 1/5: Running Flutter Doctor..."
flutter doctor || echo "⚠️  Some checks failed, but continuing..."
echo ""

# Step 3: Clean + Get Dependencies
echo "📦 Step 2/5: Cleaning and fetching dependencies..."
flutter clean
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Step 4: Static Analysis
echo "🔍 Step 3/5: Running static analysis..."
flutter analyze lib/config/api_config.dart \
                lib/services/api_client.dart \
                lib/services/auth_service.dart \
                lib/providers/auth_provider.dart \
                lib/screens/dashboard_screen.dart \
                lib/screens/welcome_screen.dart \
                lib/screens/compatibility_lab_screen.dart

if [ $? -eq 0 ]; then
  echo "✅ Static analysis passed"
else
  echo "❌ Static analysis failed. Fix errors before building."
  exit 1
fi
echo ""

# Step 5: Verify API Configuration
echo "🌐 Step 4/5: Verifying API configuration..."
API_DEFAULT=$(grep -E "defaultValue:" lib/config/api_config.dart | head -n 1 || true)

if echo "$API_DEFAULT" | grep -q "backend.soulsync.solutions/api"; then
  echo "✅ Production API default is configured for Coolify:"
  echo "   https://backend.soulsync.solutions/api"
elif echo "$API_DEFAULT" | grep -q "localhost"; then
  echo "❌ ERROR: API default is pointing to localhost!"
  echo "   Fix lib/config/api_config.dart before submitting."
  exit 1
else
  echo "⚠️  Could not verify API default from lib/config/api_config.dart"
  echo "   Current line: $API_DEFAULT"
fi
echo "ℹ️  Release override supported via:"
echo "   flutter build ios --release --dart-define=API_BASE_URL=https://backend.soulsync.solutions/api"
echo ""

# Step 6: Build iOS Release
echo "🛠  Step 5/5: Building iOS release binary..."
echo "   (This may take 2-5 minutes...)"
flutter build ios --release

if [ $? -eq 0 ]; then
  echo ""
  echo "======================================"
  echo "✅ Build Successful!"
  echo "======================================"
  echo ""
  echo "📱 Next Steps:"
  echo ""
  echo "1. Open Xcode:"
  echo "   open ios/Runner.xcworkspace"
  echo ""
  echo "2. In Xcode:"
  echo "   - Select 'Any iOS Device' as target"
  echo "   - Product → Archive"
  echo "   - Wait for archive to complete"
  echo "   - Click 'Distribute App'"
  echo "   - Choose 'App Store Connect'"
  echo "   - Follow prompts to upload"
  echo ""
  echo "3. In App Store Connect:"
  echo "   - Go to your app's page"
  echo "   - Select 'TestFlight' tab"
  echo "   - Wait for processing (10-30 min)"
  echo "   - Test with demo account:"
  echo "     Email: test.user@soulsync.demo"
  echo "     Password: DemoAccount123!"
  echo ""
  echo "4. Submit for Review:"
  echo "   - Go to 'App Store' tab"
  echo "   - Create new version"
  echo "   - Fill metadata (use updated descriptions)"
  echo "   - Submit for review"
  echo "   - Reply to previous rejection with:"
  echo "     APP_STORE_RESPONSE_LETTER.md"
  echo ""
  echo "======================================"
  echo "Demo Account Details (for reviewers):"
  echo "======================================"
  echo "Email:    test.user@soulsync.demo"
  echo "Password: DemoAccount123!"
  echo ""
  echo "✨ Your app is ready for submission!"
else
  echo ""
  echo "❌ Build failed. Check errors above and run:"
  echo "   flutter build ios --release --verbose"
  exit 1
fi
