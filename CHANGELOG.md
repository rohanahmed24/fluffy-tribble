# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-11-05

### 🎉 Major Refinements & Enhancements

This release takes the project from a rough build to a polished, production-ready application with comprehensive error handling, better UX, and improved code quality.

### Added

#### Features
- ✨ **Image History Accumulation**: Images now accumulate in the gallery instead of being replaced on each generation
- 🗑️ **Clear All Images**: New button to clear the entire image gallery with confirmation dialog
- 👆 **Interactive Image Viewer**: Tap images to view full size with controls
- 📋 **Copy Prompt Functionality**: Copy image prompts to clipboard for reuse
- 🔗 **Share Image URLs**: Share generated image URLs directly from the viewer
- 🌓 **Dark Mode Support**: Full dark theme with system-wide theme detection
- 🔄 **Automatic Retry Logic**: Network requests retry up to 3 times with exponential backoff (2s, 4s, 8s delays)
- ⏱️ **Request Timeouts**: 60-second timeout configuration for API requests
- 📝 **Comprehensive Documentation**: Added dartdoc comments to all public APIs

#### Error Handling
- 🎯 **Specific Error Messages**: Distinct error messages for different failure scenarios:
  - Authentication errors (401/403)
  - Rate limiting (429)
  - Network failures
  - Timeout errors
  - Server errors (5xx)
  - Validation errors
- 🔍 **Better Error Reporting**: User-friendly error messages without leaking sensitive data

#### Code Quality
- 🧪 **Enhanced Lint Rules**: Added 50+ strict lint rules for code quality
- 📊 **Strong Mode**: Enabled implicit-casts and implicit-dynamic checks
- 🏗️ **Better Architecture**: Improved separation of concerns with custom exception types

### Changed

#### API Client
- 🔧 **Refactored API Client**: Complete rewrite with better async/await patterns
- 🔐 **Updated API Endpoint**: Changed to Ideogram API v2 (`/generate` endpoint)
- 📝 **Better Request Format**: Updated to use `image_request` structure
- 🎨 **Aspect Ratio Mapping**: Smart conversion from decimal to API aspect ratio strings

#### UI/UX Improvements
- 🎨 **Material 3 Theming**: Both light and dark themes
- 💬 **Better User Feedback**: Loading states and progress indicators
- 🖼️ **Image Grid Interactions**: Clickable images with visual feedback
- ⚠️ **Confirmation Dialogs**: Added for destructive actions (clear all, delete key)

#### State Management
- 🔄 **Enhanced State Class**: Better state handling with proper error management
- 🧹 **Cleanup on Key Deletion**: Images are now cleared when API key is deleted
- 📦 **New Methods**: Added `clearImages()` for gallery management

### Fixed

- 🐛 **Critical Bug**: Fixed image replacement issue - images now accumulate properly
- 🔒 **Security**: Improved error messages to avoid leaking sensitive information
- 📱 **Context Usage**: Added proper context mounting checks
- 🎯 **Type Safety**: Better null safety and type checking

### Development

- ✅ **Code Documentation**: Added comprehensive dartdoc comments
- 📝 **README Update**: Complete rewrite with detailed usage instructions
- 🏗️ **Architecture Docs**: Added architecture overview
- 📋 **Changelog**: Created this changelog to track all improvements

### Technical Details

#### New Dependencies
No new dependencies added - improvements use existing packages

#### API Changes
- Updated base URL from `/v1/images` to `/generate`
- Changed request body structure to use `image_request` wrapper
- Added aspect ratio string mapping (ASPECT_1_1, ASPECT_16_9, etc.)

#### Breaking Changes
⚠️ **API Key Required**: The updated API endpoint may require a new API key from Ideogram
⚠️ **Request Format**: The API request format has changed to match Ideogram API v2

### Migration Guide

If you're upgrading from v1.0.0:

1. **Update .env file**: Already updated to use the new endpoint
2. **No code changes needed**: All changes are backward compatible from a usage perspective
3. **Clear old images**: Use the new "Clear All" button to start fresh

---

## [1.0.0] - 2025-11-05

### Initial Release

- 🔐 Secure API key storage using flutter_secure_storage
- ✨ Image generation via Ideogram API
- 🎨 6 predefined visual styles
- 📐 Adjustable aspect ratios
- 📱 Material 3 interface
- 🛡️ Input validation and error handling
- 🔑 Manual and JSON API key import

---

## Legend

- 🎉 Major release
- ✨ New feature
- 🐛 Bug fix
- 🔧 Refactor/improvement
- 🔒 Security enhancement
- 📝 Documentation
- ⚠️ Breaking change
- 🗑️ Removal/deprecation
