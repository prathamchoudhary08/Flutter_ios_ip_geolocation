#!/bin/bash

set -e

# Define output and product paths
OUTPUT="../build/ios_integ"
PRODUCT="build/ios_integ/Build/Products"

# Step 1: Clean old builds
flutter clean

# Step 2: Build iOS test app (device only, not simulator)
flutter build ios integration_test/app_test.dart --release

# Step 3: Build for testing using xcodebuild
pushd ios
xcodebuild build-for-testing \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath "$OUTPUT" \
  -sdk iphoneos \
  -allowProvisioningUpdates
popd

# Step 4: Create zip with the .xctestrun file and the test runner
pushd "$PRODUCT"
RUNNER_PATH=$(find . -type f -name "Runner_*.xctestrun" | head -n 1)

if [[ -z "$RUNNER_PATH" ]]; then
  echo "❌ .xctestrun file not found!"
  exit 1
fi

ZIP_NAME="ios_tests.zip"
ZIP_DIR="$(dirname "$RUNNER_PATH")"

echo "✅ Found .xctestrun at $RUNNER_PATH"
echo "📦 Zipping contents..."

zip -r "$ZIP_NAME" "Release-iphoneos" "$RUNNER_PATH"
popd

echo "✅ iOS test build and zip completed. Find your zip at: $PRODUCT/$ZIP_NAME"
