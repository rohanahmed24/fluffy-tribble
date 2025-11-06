#!/bin/bash

# Rogen - Vercel Deployment Script
# One-command deployment to Vercel

set -e

echo "🚀 Deploying Rogen v1.0 to Vercel..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter not found${NC}"
    echo "Install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Vercel CLI...${NC}"
    npm install -g vercel
fi

# Build web version
echo -e "${BLUE}🔨 Building web version...${NC}"
flutter clean
flutter pub get
flutter config --enable-web
flutter build web --release

# Deploy to Vercel
echo -e "${BLUE}☁️  Deploying to Vercel...${NC}"
cd build/web
vercel --prod

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "Your app is live! 🎉"
echo ""
