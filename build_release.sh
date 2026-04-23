#!/bin/bash

# Build Release script for Reservaloya Admin
# Usage: 
#   ./build_release.sh          - Build release (default)
#   ./build_release.sh debug   - Build debug
#   ./build_release.sh clean  - Clean before build

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD_TYPE="release"
CLEAN=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        debug)
            BUILD_TYPE="debug"
            ;;
        release)
            BUILD_TYPE="release"
            ;;
        clean)
            CLEAN="true"
            ;;
    esac
done

# Production variables
API_URL="https://api.reservaloya.cl/api"
AUTH0_DOMAIN="auth.reservaloya.cl"
AUTH0_CLIENT_ID="gSv4eupv6F0eRjctmIKrCNzK7Z535Xp9"
AUTH0_AUDIENCE="https://dev-8obo6dl4.us.auth0.com/api/v2/"

if [ "$CLEAN" == "true" ]; then
    echo "========================================"
    echo "Cleaning build artifacts..."
    echo "========================================"
    flutter clean
    flutter pub get
    echo "========================================"
    echo "Clean complete!"
    echo "========================================"
fi

echo "========================================"
echo "Building $BUILD_TYPE APK..."
echo "API_URL: $API_URL"
echo "AUTH0_DOMAIN: $AUTH0_DOMAIN"
echo "========================================"

FLUTTER_BUILD_TYPE="--$BUILD_TYPE"

flutter build apk "$FLUTTER_BUILD_TYPE" \
  --dart-define="API_URL=$API_URL" \
  --dart-define="AUTH0_DOMAIN=$AUTH0_DOMAIN" \
  --dart-define="AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID" \
  --dart-define="AUTH0_AUDIENCE=$AUTH0_AUDIENCE"

mv build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk build/app/outputs/flutter-apk/ReservaloYA-1.0.0.apk

echo "========================================"
echo "Build complete!"
echo "APK: build/app/outputs/flutter-apk/ReservaloYA-1.0.0.apk"
echo "========================================"
