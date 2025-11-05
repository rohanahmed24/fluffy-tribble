# CircleCI Setup for Flutter APK Builds

## 🎯 Why CircleCI?

Since GitHub Actions is unavailable due to billing issues, we're using CircleCI as an alternative. CircleCI offers:

- ✅ **6,000 free build minutes per month** (for public repos)
- ✅ **Credit card not required** for free tier
- ✅ **Excellent Flutter support**
- ✅ **Fast build times** with caching
- ✅ **Easy GitHub integration**

## 🚀 Quick Setup (5 minutes)

### Step 1: Sign Up for CircleCI

1. Go to: **https://circleci.com/signup/**
2. Click **"Sign Up with GitHub"**
3. Authorize CircleCI to access your GitHub account
4. You'll be redirected to the CircleCI dashboard

### Step 2: Add Your Project

1. In the CircleCI dashboard, click **"Projects"** in the left sidebar
2. Find **"fluffy-tribble"** in the list
3. Click **"Set Up Project"**
4. Select **"Use Existing Config"** (we already have `.circleci/config.yml`)
5. Click **"Start Building"**

That's it! CircleCI will automatically start building your APK.

## 📥 Downloading Your APK

### After Build Completes (~5-10 minutes):

1. Go to the **CircleCI dashboard**: https://app.circleci.com/
2. Click on your project: **fluffy-tribble**
3. Click on the latest build (green ✓)
4. Click the **"Artifacts"** tab
5. Download your APK files:
   - `app-arm64-v8a-release.apk` ⭐ (Most users - modern phones)
   - `app-armeabi-v7a-release.apk` (Older phones)
   - `app-x86_64-release.apk` (Emulators)

## 🔄 When Builds Trigger

Builds automatically trigger on:
- ✅ Push to `main` branch
- ✅ Push to any `claude/*` branch
- ✅ Tags (for releases)

## 📊 Build Status Badge (Optional)

Add this to your README to show build status:

```markdown
[![CircleCI](https://circleci.com/gh/rohanahmed24/fluffy-tribble.svg?style=svg)](https://circleci.com/gh/rohanahmed24/fluffy-tribble)
```

## 🏷️ Creating Releases (Optional)

To automatically create GitHub releases with APKs:

### 1. Create a GitHub Personal Access Token:

1. Go to: https://github.com/settings/tokens/new
2. Give it a name: "CircleCI Release Token"
3. Check these permissions:
   - `repo` (Full control of private repositories)
4. Click **"Generate token"**
5. **Copy the token** (you won't see it again!)

### 2. Add Token to CircleCI:

1. In CircleCI, go to **Project Settings** → **Environment Variables**
2. Click **"Add Environment Variable"**
3. Name: `GITHUB_TOKEN`
4. Value: Paste your GitHub token
5. Click **"Add"**

### 3. Uncomment Release Job:

In `.circleci/config.yml`, uncomment the release job at the bottom:

```yaml
workflows:
  version: 2
  build-and-deploy:
    jobs:
      - build-apk:
          # ... existing config ...

      # Uncomment these lines:
      - create-release:
          requires:
            - build-apk
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /^v.*/
```

### 4. Create a Release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

CircleCI will build and create a GitHub release automatically!

## 💰 Free Tier Limits

CircleCI Free Tier includes:
- **6,000 build minutes/month** for public repos
- **1 concurrent build**
- **Unlimited projects**
- **Unlimited users**
- **Artifacts stored for 30 days**

This is plenty for your Flutter project!

## ⚙️ Configuration Details

### Build Steps:

1. **Checkout code** from GitHub
2. **Install Flutter 3.16.0**
3. **Create .env file** (required for app)
4. **Install dependencies** (`flutter pub get`)
5. **Analyze code** (optional, non-blocking)
6. **Build APK** (release mode, split by ABI)
7. **Store APK artifacts** (available for download)

### Build Time:

- **First build:** ~8-12 minutes (downloads Flutter SDK)
- **Subsequent builds:** ~4-6 minutes (uses cache)

## 🔧 Troubleshooting

### Build not starting?
- Make sure you clicked "Set Up Project" in CircleCI
- Check that the config file is at `.circleci/config.yml`
- Verify your GitHub repo is public (or CircleCI has access)

### Build failing?
- Check the CircleCI build logs for errors
- Common issues: syntax errors, dependency conflicts
- Test locally first: `flutter build apk --release`

### Can't find artifacts?
- Artifacts only appear after successful builds
- Look for the green ✓ checkmark
- Artifacts expire after 30 days

## 🆚 CircleCI vs GitHub Actions

| Feature | CircleCI Free | GitHub Actions Free |
|---------|---------------|---------------------|
| Build minutes | 6,000/month | 2,000/month |
| Concurrent builds | 1 | 20 |
| Build speed | Fast | Fast |
| Credit card required | No | No* |
| Works with billing issues | Yes ✅ | No ❌ |

*GitHub Actions requires account in good standing

## 📱 Next Steps

After your first build completes:

1. ✅ Download the APK from CircleCI artifacts
2. ✅ Install on your Android device
3. ✅ Configure your preferred AI provider (Ideogram, OpenAI, Stability AI, or Replicate)
4. ✅ Start generating images!

---

**Need Help?**

- CircleCI Docs: https://circleci.com/docs/
- Flutter on CircleCI: https://circleci.com/docs/language-flutter/
- This project's docs: See main [README.md](../README.md) and [API_SETUP.md](../API_SETUP.md)
