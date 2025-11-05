# GitHub Actions Workflows

## Build APK Workflow

### Overview
The `build-apk.yml` workflow automatically builds Android APK files for the Flutter app whenever changes are pushed to the repository.

### Triggers

The workflow runs on:
- **Push to main branch**: Builds release APK
- **Push to claude/** branches**: Builds release APK for feature branches
- **Pull requests**: Builds debug APK for testing
- **Manual trigger**: Can be triggered manually from GitHub Actions tab

### Build Types

#### Release Build (Push events)
- Builds optimized release APKs
- Splits APKs per ABI (arm64-v8a, armeabi-v7a, x86_64)
- Smaller file sizes, optimized for production
- APK files: `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`

#### Debug Build (Pull requests)
- Builds debug APK for testing
- Single universal APK
- Larger file size but works on all devices
- APK file: `app-debug.apk`

### Artifacts

After a successful build, the following artifacts are available:

1. **APK files**: Available for download from the Actions run
   - Retention: 30 days
   - Location: Actions → Workflow Run → Artifacts section

2. **Release info**: Build metadata (main branch only)
   - Build date and time
   - Commit hash
   - APK file sizes

### Downloading APKs

#### From GitHub Actions:

1. Go to the **Actions** tab in your repository
2. Click on the workflow run you want
3. Scroll to the **Artifacts** section at the bottom
4. Click on the artifact name to download

#### For Main Branch Builds:
- Artifact name: `release-apks`
- Contains: All split APKs (arm64, armeabi-v7a, x86_64)

#### For Pull Request Builds:
- Artifact name: `app-debug.apk`
- Contains: Single debug APK

### Creating a Release

To create a GitHub Release with APK files:

1. Create and push a tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. The workflow will automatically:
   - Build the APKs
   - Create a GitHub Release
   - Attach all APK files to the release
   - Generate release notes from commits

### Manual Workflow Trigger

To manually trigger a build:

1. Go to **Actions** tab
2. Select **Build Android APK** workflow
3. Click **Run workflow**
4. Select the branch
5. Click **Run workflow** button

### Requirements

The workflow automatically sets up:
- ✅ Ubuntu latest runner
- ✅ Java 17 (Zulu distribution)
- ✅ Flutter 3.16.0 (stable channel)
- ✅ Gradle caching for faster builds

No additional setup or secrets required!

### Build Time

Typical build times:
- First build: ~5-7 minutes (downloads Flutter SDK)
- Subsequent builds: ~2-4 minutes (uses cache)

### Troubleshooting

#### Build fails with "flutter: command not found"
- The workflow automatically installs Flutter, so this shouldn't happen
- If it does, check the Flutter setup step logs

#### APK not generated
- Check the build step logs for errors
- Common issues: dependency conflicts, syntax errors
- Run `flutter analyze` locally to catch issues early

#### Artifacts not appearing
- Artifacts only appear after a successful build
- Check the workflow status - it must be green (✓)
- Artifacts expire after 30 days

### Local Testing

Before pushing, test the build locally:

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release --split-per-abi

# Check APK location
ls -lh build/app/outputs/flutter-apk/
```

### APK Selection Guide

For end users, recommend:
- **arm64-v8a**: Modern 64-bit devices (2019+) - Smallest size
- **armeabi-v7a**: Older 32-bit devices (pre-2019)
- **x86_64**: Emulators and Intel-based devices (rare)
- **Universal** (debug): Works on all devices but larger

Most users should use **app-arm64-v8a-release.apk**.
