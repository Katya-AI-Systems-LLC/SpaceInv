# 🎨 Random Icon Generator - Quick Reference

## ⚡ 60-Second Quick Start

### Generate Icons (All Platforms)
```bash
python tools/generate_icons.py
```

### Generate + Rebuild (Choose One)
```bash
# For current platform
python tools/quick_icons.py --rebuild

# For web only
python tools/quick_icons.py --rebuild --web

# For Android only
python tools/quick_icons.py --rebuild --android
```

### Windows Users - Just Run This
```bash
tools\generate_icons.bat
```

### Mac/Linux Users - Just Run This
```bash
bash tools/generate_icons.sh
```

---

## 🎨 Icon Specifications

### Generated Sizes
- **Android**: 36×36, 48×48, 72×72, 96×96, 144×144, 192×192
- **iOS**: 20, 29, 40, 60, 76, 83.5, 1024 (multiple @1x/@2x/@3x)
- **Web**: 192×192, 512×512 (normal + maskable)
- **Windows**: 256×256 (ICO format)
- **macOS**: 16, 32, 64, 128, 256, 512, 1024
- **Linux**: 256×256

---

## 🔄 Regenerate Anytime

Want a completely different icon design? Just run again:

```bash
python tools/generate_icons.py
```

Each run creates a unique, randomly generated design!

---

## 🛠️ Troubleshooting

### Python Not Found
```bash
# Install Python from https://www.python.org/
# Then try again
```

### Pillow Not Installed
```bash
pip install Pillow
# Then try again
```

### Icons Still Not Updating in App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📊 What Gets Generated

| Component | Details |
|-----------|---------|
| **Total Icons** | 47 |
| **Color Schemes** | 5 (Neon, Space, Retro, Cyberpunk, Sunset) |
| **Shape Types** | 4 (Circles, Squares, Triangles, Stars) |
| **Platforms** | 6 (Android, iOS, Web, Windows, macOS, Linux) |
| **Unique Each Time** | ✅ YES |

---

## 🚀 Full Documentation

For complete details, see:
- `tools/ICON_GENERATOR_README.md` - Full guide
- `tools/ICON_GENERATION_SUMMARY.md` - Project summary
- `README.md` - Icon section in main docs

---

## 💡 Pro Tips

1. **One-Command Rebuild**: `python tools/quick_icons.py --rebuild`
2. **Keep Favorite Icons**: Backup the `web/icons/` folder before regenerating
3. **Test on Device**: After generating, test on actual device for icon quality
4. **Mass Update**: Regenerate icons before app release for fresh branding

---

**Ready? Start generating! 🎨**

```bash
python tools/generate_icons.py
```
