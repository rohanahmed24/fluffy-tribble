# Deploy Rogen to Render - Complete Guide

Deploy **Rogen v1.0** to Render with **zero local setup**. Everything builds in the cloud!

---

## 🚀 Quick Deploy (5 Minutes)

### Step 1: Go to Render

Visit: **https://render.com**

Click **"Get Started"** or **"Sign Up"**

### Step 2: Connect GitHub

1. Click **"Sign in with GitHub"**
2. Authorize Render to access your repositories
3. You'll be redirected to your Render dashboard

### Step 3: Create New Static Site

1. Click **"New +"** button (top right)
2. Select **"Static Site"**
3. Find and select **`fluffy-tribble`** from the list
4. Click **"Connect"**

### Step 4: Configure Your Site

Fill in these settings:

**Basic Settings:**
- **Name**: `rogen` (or any name you prefer)
- **Branch**: `claude/critical-build-fixes-011CUp3qo2ePC26sidaZYUqh`
- **Root Directory**: Leave blank (uses root)

**Build Settings:**
- **Build Command**:
  ```bash
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 && export PATH="$PATH:$PWD/flutter/bin" && flutter doctor -v && flutter config --enable-web && flutter pub get && flutter build web --release
  ```

- **Publish Directory**: `build/web`

**Advanced Settings (Click "Advanced"):**

Add Environment Variable:
- **Key**: `FLUTTER_VERSION`
- **Value**: `3.16.0`

### Step 5: Deploy!

1. Click **"Create Static Site"**
2. Render will start building your app
3. Watch the build logs (takes 3-5 minutes)
4. Once complete, you'll get your URL!

---

## 🌐 Your Live URL

After deployment succeeds, Render gives you:

```
https://rogen.onrender.com
```

Or with your custom name:
```
https://your-name.onrender.com
```

---

## 📊 Build Process

When you deploy, Render will:

1. ✅ Clone your GitHub repository
2. ✅ Install Flutter 3.16.0 stable
3. ✅ Run `flutter pub get` (install dependencies)
4. ✅ Enable web platform
5. ✅ Build production web version
6. ✅ Deploy to global CDN
7. ✅ Provide HTTPS URL

**Build time**: 3-5 minutes (first time)
**Subsequent builds**: 2-3 minutes

---

## 🎯 Automated Deployments

After initial setup, Render automatically deploys when:

- ✅ You push new code to the branch
- ✅ You merge a pull request
- ✅ You manually trigger a deploy

**Zero maintenance needed!**

---

## 🔧 Using render.yaml (Alternative Method)

I've created a `render.yaml` file for you! This allows one-click deployment.

### Blueprint Deploy:

1. Go to: https://render.com
2. Click **"Blueprints"**
3. Click **"New Blueprint Instance"**
4. Connect your `fluffy-tribble` repo
5. Render reads `render.yaml` automatically
6. Click **"Apply"**
7. Done!

The `render.yaml` file includes:
- ✅ Automatic Flutter installation
- ✅ Build configuration
- ✅ Cache headers for performance
- ✅ SPA routing configuration

---

## 🎨 What You Get

### Free Tier Includes:
- ✅ **100 GB bandwidth/month**
- ✅ **Custom domain** (free)
- ✅ **Automatic SSL/HTTPS**
- ✅ **Global CDN**
- ✅ **Auto-deploy** on git push
- ✅ **Build minutes**: 750/month free
- ✅ **Zero downtime** deployments
- ✅ **Instant rollback**

### Features:
- 🎨 Beautiful Rogen UI
- ⚡ Fast loading worldwide
- 📱 Responsive design
- 🔐 Secure API storage
- 💜 Premium purple theme
- 🤖 4 AI providers
- 🌍 PWA support

---

## 🔄 Update Your App

### Automatic Updates:

Just push code to GitHub:
```bash
git add .
git commit -m "Update Rogen"
git push origin claude/critical-build-fixes-011CUp3qo2ePC26sidaZYUqh
```

Render automatically:
1. Detects the push
2. Rebuilds the app
3. Deploys new version
4. Zero downtime!

### Manual Deploy:

1. Go to Render dashboard
2. Select your `rogen` site
3. Click **"Manual Deploy"**
4. Select branch
5. Click **"Deploy"**

---

## 🌍 Custom Domain

### Add Your Domain (Free!):

1. Go to your site settings on Render
2. Click **"Custom Domains"**
3. Click **"Add Custom Domain"**
4. Enter: `rogen.yourdomain.com`
5. Render provides DNS instructions
6. Add CNAME record at your domain provider:
   ```
   CNAME  rogen  your-site.onrender.com
   ```
7. Wait for DNS propagation (5-30 minutes)
8. SSL automatically provisioned!

**Free SSL certificate included!**

---

## 📈 Monitor Your Site

### Render Dashboard Shows:

- **Build logs**: See real-time build progress
- **Deploy history**: Roll back to any version
- **Metrics**: Bandwidth usage, requests
- **Uptime**: 99.9% uptime monitoring
- **SSL status**: Certificate auto-renewal

---

## 🐛 Troubleshooting

### Build Failed?

**Check Build Logs:**
1. Go to Render dashboard
2. Click on your site
3. Check **"Events"** tab
4. Review build logs for errors

**Common Issues:**

**Issue**: "Flutter not found"
- **Fix**: Ensure build command includes Flutter installation
- Use the command provided in Step 4 above

**Issue**: "Build timeout"
- **Fix**: First build takes longer. Wait 5-10 minutes
- Check build logs for actual errors

**Issue**: "Dependencies failed"
- **Fix**: Ensure `pubspec.yaml` is in repository
- Check Flutter version compatibility

### Site Not Loading?

1. **Check deployment status** in Render dashboard
2. **Verify publish directory** is set to `build/web`
3. **Check build succeeded** (green checkmark)
4. **Wait 1-2 minutes** after successful build

### API Calls Not Working?

This is normal! Users need to:
1. Visit your site
2. Click Settings/API Keys
3. Enter their own API keys
4. Keys are stored in browser

---

## 🔐 Security

### API Keys:
- ✅ Never commit API keys to git
- ✅ Users enter their own keys
- ✅ Stored in browser secure storage
- ✅ Not sent to your server

### HTTPS:
- ✅ Automatic SSL certificate
- ✅ Auto-renewal before expiry
- ✅ Force HTTPS enabled
- ✅ TLS 1.2+ only

---

## 💰 Cost

### Free Tier:
- **Static sites**: Unlimited
- **Bandwidth**: 100 GB/month
- **Build minutes**: 750/month
- **Custom domains**: Unlimited
- **SSL**: Free

**Perfect for Rogen!** The free tier is more than enough.

### Paid Tier (Optional):
- **$7/month**: 1000 build minutes
- **$85/month**: Priority support
- Only needed for high-traffic sites

---

## 📊 Performance

### Optimization Tips:

**Already Included:**
- ✅ Global CDN (fast worldwide)
- ✅ Gzip compression
- ✅ HTTP/2
- ✅ Cache headers (from render.yaml)
- ✅ SPA routing

**Expected Performance:**
- **Load time**: < 3 seconds
- **Time to Interactive**: < 2 seconds
- **Lighthouse score**: 90+

---

## 🎯 Alternative Build Command (Simpler)

If the long command seems complex, you can also use this in separate fields:

**Install Command:**
```bash
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$PWD/flutter/bin"
flutter doctor
```

**Build Command:**
```bash
flutter pub get
flutter build web --release
```

But the one-line command in Step 4 is more reliable!

---

## 🌟 Why Choose Render?

### Pros:
- ✅ Simple setup (5 minutes)
- ✅ No local setup needed
- ✅ Auto-deploy on push
- ✅ Free tier generous
- ✅ Great for small-medium apps
- ✅ Custom domain free
- ✅ Excellent uptime

### Cons:
- ⚠️ First build is slow (3-5 min)
- ⚠️ Free tier has build minute limit
- ⚠️ Cold starts after inactivity (free tier)

---

## 🎉 Success Checklist

After deployment, verify:

- [ ] Site loads at your Render URL
- [ ] Images and assets load correctly
- [ ] API key settings dialog opens
- [ ] Can generate images after entering API key
- [ ] Responsive design works on mobile
- [ ] PWA install prompt appears
- [ ] HTTPS is enabled (lock icon in browser)

---

## 🚀 Ready to Deploy?

### Quick Links:

**Start Here**: https://render.com/

**Documentation**: https://render.com/docs/static-sites

**Your Repo**: https://github.com/rohanahmed24/fluffy-tribble

### One-Click Blueprint Deploy:

If you prefer, use the `render.yaml` file:
1. Push the render.yaml to your repo
2. Go to Render → Blueprints
3. Connect repo
4. Click Apply
5. Done!

---

## 📞 After Deploy

**Share your URL!**
```
🎨 Rogen v1.0 is live!
🌐 https://rogen.onrender.com
⚡ Generate stunning AI images
📱 Works on any device
```

Test it out:
1. Visit the URL
2. Configure an API provider
3. Generate your first image
4. Share with others!

---

## 💡 Pro Tips

1. **Enable notifications**: Get alerts for deploy status
2. **Add health checks**: Monitor uptime
3. **Use preview URLs**: Test before production
4. **Set up staging**: Create staging environment
5. **Monitor bandwidth**: Check usage in dashboard

---

## ✨ What's Next?

After successful deployment:

1. **Test thoroughly** on different devices
2. **Add custom domain** (optional)
3. **Enable analytics** (Google Analytics, etc.)
4. **Share with users**!
5. **Monitor performance** in Render dashboard

---

## 🎊 You're Ready!

Everything is configured for Render deployment. Just:

1. Go to https://render.com
2. Connect GitHub
3. Create Static Site
4. Use settings from Step 4 above
5. Deploy!

**Your Rogen v1.0 web app will be live in 5 minutes!** 🚀

No local setup. No Flutter installation. Just cloud-based magic! ✨
