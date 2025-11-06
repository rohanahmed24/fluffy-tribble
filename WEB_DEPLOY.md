# Rogen Web Deployment Guide

Complete guide to building and deploying **Rogen v1.0** as a web application.

---

## 🚀 Quick Start

### Build Web Version

```bash
# Option 1: Use the build script (recommended)
./build_web.sh

# Option 2: Manual build
flutter build web --release
```

### Test Locally

```bash
cd build/web
python3 -m http.server 8000
# Visit: http://localhost:8000
```

---

## 📦 Build Output

After building, you'll have:

```
build/web/
├── index.html          # Main HTML file
├── main.dart.js        # Compiled Dart code
├── flutter.js          # Flutter engine
├── manifest.json       # PWA manifest
├── favicon.png         # App icon
├── icons/              # PWA icons (192px, 512px)
├── assets/             # App assets
│   ├── fonts/
│   ├── images/
│   └── NOTICES
└── canvaskit/          # Canvas rendering
```

**Total size**: ~2-5 MB (compressed)

---

## 🌐 Deployment Options

### Option 1: Firebase Hosting (Recommended)

**Free tier**: 10 GB storage, 360 MB/day transfer

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
firebase init hosting

# Select options:
# - What do you want to use as your public directory? build/web
# - Configure as single-page app? Yes
# - Set up automatic builds with GitHub? (Optional) Yes

# Deploy
firebase deploy

# Your app will be live at:
# https://your-project.firebase app.com
```

**Custom domain**: Free with Firebase Hosting

---

### Option 2: Netlify

**Free tier**: 100 GB bandwidth/month

#### Via Drag & Drop
1. Go to https://app.netlify.com/drop
2. Drag `build/web` folder
3. Done! App is live

#### Via CLI
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=build/web

# Follow prompts
# Your app will be live at: https://random-name.netlify.app
```

**Custom domain**: Free with Netlify

---

### Option 3: Vercel

**Free tier**: Unlimited bandwidth, edge caching

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd build/web
vercel --prod

# Your app will be live at:
# https://your-project.vercel.app
```

**Custom domain**: Free with Vercel

---

### Option 4: GitHub Pages

**Free tier**: Unlimited (for public repos)

```bash
# Build
flutter build web --base-href "/rogen/"

# Create gh-pages branch
git checkout --orphan gh-pages
git rm -rf .
cp -r build/web/* .
git add .
git commit -m "Deploy Rogen v1.0"
git push origin gh-pages

# Enable in GitHub Settings > Pages
# Your app will be at:
# https://yourusername.github.io/rogen/
```

---

### Option 5: Cloudflare Pages

**Free tier**: Unlimited bandwidth, global CDN

1. Go to Cloudflare Dashboard
2. Pages → Create a project
3. Connect GitHub repo
4. Build settings:
   - Build command: `flutter build web`
   - Build output: `build/web`
5. Deploy

**Custom domain**: Free with Cloudflare

---

### Option 6: AWS S3 + CloudFront

**For high-traffic production apps**

```bash
# Build
flutter build web --release

# Upload to S3
aws s3 sync build/web s3://your-bucket-name --delete

# Configure CloudFront for HTTPS and CDN
# Point domain to CloudFront distribution
```

---

### Option 7: Self-Hosted (Nginx)

**Complete control, your own server**

```nginx
# /etc/nginx/sites-available/rogen
server {
    listen 80;
    server_name rogen.example.com;

    root /var/www/rogen;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# Copy files
sudo cp -r build/web/* /var/www/rogen/

# Enable site
sudo ln -s /etc/nginx/sites-available/rogen /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Set up SSL with Let's Encrypt
sudo certbot --nginx -d rogen.example.com
```

---

## 🔧 Build Optimization

### Reduce Bundle Size

```bash
# Use HTML renderer (smaller but fewer features)
flutter build web --web-renderer html

# Use CanvasKit renderer (larger but better performance)
flutter build web --web-renderer canvaskit

# Tree shaking (remove unused code)
flutter build web --release --tree-shake-icons
```

### Enable PWA Features

Already configured in `web/manifest.json`:
- ✅ Install prompt
- ✅ Offline support
- ✅ App icons
- ✅ Splash screen

### Performance Tips

1. **Enable compression** (gzip/brotli)
2. **Use CDN** for static assets
3. **Enable HTTP/2**
4. **Set cache headers**
5. **Lazy load images**

---

## 🎯 Post-Deployment Checklist

### Test Your Deployment

- [ ] Visit the URL in browser
- [ ] Test image generation
- [ ] Test provider switching
- [ ] Check PWA install prompt (mobile)
- [ ] Test offline mode (PWA)
- [ ] Verify responsive design (mobile/desktop)
- [ ] Check API key storage works
- [ ] Test all 4 AI providers

### Performance

- [ ] Run Lighthouse audit (aim for 90+ score)
- [ ] Check load time (< 3 seconds)
- [ ] Verify mobile performance
- [ ] Test on slow connection

### SEO & Metadata

- [ ] Verify page title: "Rogen"
- [ ] Check meta description
- [ ] Ensure social media preview works
- [ ] Set up analytics (optional)

---

## 📊 Comparison Table

| Service | Free Tier | Custom Domain | SSL | CDN | Build Minutes |
|---------|-----------|---------------|-----|-----|---------------|
| **Firebase** | 10 GB storage | ✅ Free | ✅ Auto | ✅ Global | Manual |
| **Netlify** | 100 GB bandwidth | ✅ Free | ✅ Auto | ✅ Global | 300/month |
| **Vercel** | Unlimited | ✅ Free | ✅ Auto | ✅ Edge | Unlimited |
| **GitHub Pages** | Unlimited | ❌ Paid | ✅ Auto | ✅ GitHub | N/A |
| **Cloudflare** | Unlimited | ✅ Free | ✅ Auto | ✅ Global | 500/month |

**Recommendation**:
- **Hobbyist**: Netlify or Vercel (easiest)
- **Professional**: Firebase or Cloudflare Pages
- **Enterprise**: AWS CloudFront or self-hosted

---

## 🔐 Security Considerations

### API Keys
- ⚠️ Never commit API keys to git
- ✅ API keys stored in browser's secure storage
- ✅ Each user enters their own keys
- ✅ Keys never sent to your server

### HTTPS
- ✅ All modern hosting includes free SSL
- ✅ Required for PWA features
- ✅ Required for secure storage API

### CORS
- ✅ API providers handle CORS
- ✅ All AI provider APIs support browser requests

---

## 🌍 Custom Domain Setup

### Firebase Hosting

```bash
firebase hosting:channel:deploy live --only hosting
firebase hosting:sites:create rogen
firebase target:apply hosting rogen rogen
# Add domain in Firebase Console
```

### Netlify

1. Go to Domain settings
2. Add custom domain
3. Update DNS:
   ```
   CNAME  rogen  your-app.netlify.app
   ```

### Vercel

1. Project Settings → Domains
2. Add your domain
3. Update DNS as shown

---

## 📱 PWA Installation

Once deployed, users can install Rogen as an app:

### Desktop (Chrome/Edge)
1. Visit your website
2. Click install icon in address bar
3. Click "Install"

### Mobile (Android/iOS)
1. Visit website in browser
2. Tap "Add to Home Screen"
3. App appears on home screen

**Features**:
- Standalone window
- App icon on home screen/dock
- Offline support (with service worker)
- Fast loading from cache

---

## 🎨 Branding Assets

Update these for your deployment:

- `web/icons/Icon-192.png` - PWA icon (192x192)
- `web/icons/Icon-512.png` - PWA icon (512x512)
- `web/favicon.png` - Browser favicon
- `web/manifest.json` - PWA configuration

---

## 🐛 Troubleshooting

### Build fails

```bash
flutter clean
flutter pub get
flutter build web --release
```

### White screen after deployment

- Check browser console for errors
- Verify `--base-href` matches deployment path
- Ensure all files uploaded

### PWA not working

- Ensure HTTPS is enabled
- Check `manifest.json` is accessible
- Verify service worker registered

### API calls failing

- Check browser console for CORS errors
- Verify API keys are entered
- Test API keys with curl

---

## 📈 Analytics (Optional)

### Google Analytics

Add to `web/index.html`:

```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## 🎉 Success!

Your Rogen web app is now live! Share the URL:

```
🌐 https://your-domain.com
🎨 Gorgeous UI
⚡ Fast & Responsive
📱 Works on all devices
🔒 Secure API storage
```

---

## 📞 Support

Issues? Check:
- [Flutter Web Docs](https://flutter.dev/web)
- [Rogen GitHub Issues](https://github.com/yourusername/rogen/issues)
- Build logs in your hosting dashboard

**Happy deploying! 🚀**
