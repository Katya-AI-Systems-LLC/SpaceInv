# Space Invaders Game

A Flutter implementation of the classic Space Invaders arcade game with modern improvements and features.

## Features

### Core Gameplay
- ✅ Player movement (keyboard arrows, touch drag)
- ✅ Shooting mechanics (spacebar or tap)
- ✅ Enemy waves with different types (normal, fast, strong)
- ✅ Enemy movement patterns
- ✅ Collision detection
- ✅ Lives system (3 lives)
- ✅ Scoring system

### Advanced Features
- ✅ **Level progression** - Enemies increase with each level
- ✅ **Enemy bullets** - Enemies can shoot back
- ✅ **Particle effects** - Explosions when enemies are destroyed
- ✅ **Invulnerability** - Temporary shield and animated aura after taking damage
- ✅ **Pause functionality** - Press P or ESC to pause
- ✅ **High score tracking & local leaderboard** - Saves best scores locally
- ✅ **Game over screen** - Shows stats, achievements update and allows restart
- ✅ **Start menu** - Beautiful menu screen with controls and mode selection
- ✅ **Visual effects** - Starfield background, particle explosions, animated enemies
- ✅ **Multiple enemy types** - Normal, fast, strong and kamikaze divers
- ✅ **Boss levels** - Strong bosses every few levels with second attack phase
- ✅ **Power-ups** - Multi-shot, shield, speed boost, extra life
- ✅ **Achievements** - Local achievements based on StatisticsService
- ✅ **Game modes** - Classic, Survival, Hardcore

## Controls

### Keyboard
- **← →** Arrow keys: Move player
- **SPACE**: Shoot
- **P / ESC**: Pause/Resume

### Touch/Mouse
- **Tap**: Shoot
- **Drag**: Move player horizontally

## Game Mechanics

- **Lives**: Start with 3 lives. Lose a life when hit by enemy or enemy bullet
- **Invulnerability**: 2 seconds of invulnerability after taking damage (blue glow)
- **Enemy Types**:
  - Normal (Yellow): 10 points
  - Fast (Red): 20 points  
  - Strong (Purple): 15 points
- **Level Progression**: Each level adds more enemies and increases difficulty
- **Enemy Shooting**: Enemies periodically shoot bullets at the player

## Project Structure (simplified)

```
lib/
├── main.dart                        # App entry point
├── game_state.dart                  # Game state management
├── collision_detection.dart         # Collision logic
├── enemy_movement.dart              # Enemy movement controller
├── models/
│   ├── power_up.dart                # Power-up model
│   └── game_mode.dart               # Game mode enum
├── services/
│   ├── audio_service.dart           # Audio system
│   ├── statistics_service.dart      # Statistics tracking
│   ├── achievements_service.dart    # Achievements system
│   ├── leaderboard_service.dart     # Local (and optional online) leaderboard
│   ├── online_leaderboard_client.dart # Online leaderboard abstraction
│   └── localization_service.dart    # Simple RU/EN localization
├── screens/
│   ├── start_menu_screen.dart       # Start menu with modes & navigation
│   ├── game_screen.dart             # Main game screen
│   ├── game_over_screen.dart        # Game over summary
│   ├── statistics_screen.dart       # Statistics UI
│   ├── achievements_screen.dart     # Achievements UI
│   ├── leaderboard_screen.dart      # Local leaderboard UI
│   └── settings_screen.dart         # Audio & language settings
└── widgets/
    ├── player.dart
    ├── enemy.dart
    ├── bullet.dart
    ├── power_up.dart
    └── barrier.dart
```

## Assets

The game uses fallback colored widgets if image assets are not found. To add custom sprites:

1. Create images in `assets/images/`:
   - `player.png` (50x50 recommended)
   - `enemy.png` (40x40 recommended)
   - `bullet.png` (5x15 recommended)

2. The game will automatically use them if present, otherwise uses colorful widget fallbacks.

## 🎨 Random Icon Generator

The project includes a random icon generator that creates unique app icons for all platforms!

### Quick Start

```bash
# Generate random icons for all platforms
python tools/generate_icons.py

# Or use the quick helper (with optional rebuild)
python tools/quick_icons.py --rebuild

# For Windows, just run the batch file
tools\generate_icons.bat

# For Mac/Linux
bash tools/generate_icons.sh
```

### What it Does

- ✅ Generates 47 unique icons for all platforms
- ✅ Supports Android, iOS, Web, Windows, macOS, Linux
- ✅ Uses random color palettes (Neon, Space, Cyberpunk, etc.)
- ✅ Creates geometric shapes (circles, squares, triangles, stars)
- ✅ Adds glow border effects
- ✅ Each run creates a completely different design!

### Platforms & Sizes

| Platform | Icons | Sizes |
|----------|-------|-------|
| Android | 6 | ldpi, mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi |
| iOS | 15 | 20, 29, 40, 60, 76, 83.5, 1024 (various scales) |
| Web | 4 | 192, 512 (normal + maskable) |
| Windows | 1 | 256x256 (ICO format) |
| macOS | 7 | 16, 32, 64, 128, 256, 512, 1024 |
| Linux | 1 | 256x256 |

### Files

- `tools/generate_icons.py` - Main Python generator
- `tools/quick_icons.py` - Quick helper with rebuild options
- `tools/generate_icons.bat` - Windows batch runner
- `tools/generate_icons.sh` - Mac/Linux shell runner
- `tools/ICON_GENERATOR_README.md` - Detailed documentation

### Rebuild After Icon Changes

```bash
flutter clean
flutter pub get
flutter run
```

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the game:
   ```bash
   flutter run
   ```

3. Build for web:
   ```bash
   flutter build web
   ```

4. Build for mobile:
   ```bash
   flutter build apk  # Android
   flutter build ios  # iOS
   ```

## Dependencies

- `shared_preferences: ^2.2.2` - For saving high scores, stats and settings
- `audioplayers: ^5.2.1` - For sound effects and background music
- `http: ^1.2.0` - For optional online leaderboard REST client

## Features Beyond Core Plan

### 🎵 Audio System
- Background music support
- Sound effects for shooting and explosions
- Adjustable volume controls (separate for music and effects)
- Settings to enable/disable audio

### 📊 Statistics Tracking
- Games played counter
- Total score across all games
- Highest level reached
- Total enemies killed
- Win/loss tracking
- Win rate percentage
- Beautiful statistics screen with visual cards

### ⚙️ Settings Screen
- Audio controls (sound effects and music toggle)
- Volume sliders for fine-tuning
- Settings persistence across sessions

### 🎁 Power-ups System
- Multi-shot power-up
- Shield power-up
- Speed boost power-up
- Life-up power-up

## Web Version

The project also includes a separate web version implementation in the `web/` directory with enhanced features like:
- Canvas-based rendering
- Advanced particle effects
- Power-ups system
- Enhanced UI

## Online Leaderboard (API Hooks)

The app includes a pluggable online leaderboard client.

- Local leaderboard always works offline via `SharedPreferences`.
- Online sync is **disabled by default**.
- To enable it, provide a backend and configure:

```bash
flutter run \
  --dart-define=LEADERBOARD_API_BASE_URL=https://your.api \
  --dart-define=LEADERBOARD_API_KEY=optional_key
```

The backend is expected to expose:

- `GET  /leaderboard` – returns a JSON array or `{ "entries": [...] }`
- `POST /leaderboard` – accepts a single leaderboard entry JSON

Entry JSON format matches `LeaderboardEntry.toJson()`:

```json
{
  "score": 1234,
  "level": 7,
  "mode": "GameMode.classic",
  "date": "2025-01-01T12:00:00.000Z"
}
```

You are free to implement this backend using any technology (Firebase, REST, etc.).

## Additional Documentation

- `docs/ARCHITECTURE.md` – detailed overview of the current game architecture and how systems (campaign, meta‑progression, AI hooks) fit together.
- `docs/PLATFORM_SUPPORT.md` – platform matrix for Android/iOS/Web/Windows/macOS/Linux and notes on experimental targets (UWP, Aurora‑like systems).
- `docs/AI_QUANTUM_ENGINE.md` – forward‑looking design for integrating external AI agents, services, and optional web3/blockchain bridges with the game.
- `docs/GIT_SYSTEMS.md` – notes on using this repository across multiple git forges (GitHub/GitLab/etc. and domestic platforms via `git_systems/`).

## License

This project is open source and available for educational purposes.
