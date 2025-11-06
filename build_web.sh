#!/bin/bash

# Rogen Web Build Script
# Builds the web version of Rogen for production deployment

set -e  # Exit on error

echo "🚀 Building Rogen Web v1.0..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${BLUE}📋 Flutter version:${NC}"
flutter --version
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${YELLOW}⚠️  Not in Flutter project directory${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

# Enable web
echo -e "${BLUE}🌍 Enabling web platform...${NC}"
flutter config --enable-web

# Build for web (release mode)
echo -e "${BLUE}🔨 Building web release...${NC}"
flutter build web --release \
    --web-renderer html \
    --base-href "/" \
    --pwa-strategy offline-first

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Web build successful!${NC}"
    echo ""
    echo -e "${GREEN}📁 Build output: build/web/${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Test locally: cd build/web && python3 -m http.server 8000"
    echo "2. Deploy to hosting (see WEB_DEPLOY.md)"
    echo ""

    # Show build size
    if command -v du &> /dev/null; then
        BUILD_SIZE=$(du -sh build/web | cut -f1)
        echo -e "${BLUE}📊 Build size: ${BUILD_SIZE}${NC}"
    fi

    # List main files
    echo ""
    echo -e "${BLUE}📄 Main files:${NC}"
    ls -lh build/web/*.{html,js,json} 2>/dev/null || true

else
    echo ""
    echo -e "${YELLOW}❌ Build failed${NC}"
    exit 1
fi
