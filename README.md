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
- ✅ **Invulnerability** - Temporary shield after taking damage
- ✅ **Pause functionality** - Press P or ESC to pause
- ✅ **High score tracking** - Saves best score locally
- ✅ **Game over screen** - Shows stats and allows restart
- ✅ **Start menu** - Beautiful menu screen with controls
- ✅ **Visual effects** - Starfield background, particle explosions
- ✅ **Multiple enemy types** - Different colors and behaviors

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

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── game_state.dart           # Game state management
├── collision_detection.dart  # Collision logic
├── enemy_movement.dart       # Enemy movement controller
├── screens/
│   ├── start_menu_screen.dart
│   ├── game_screen.dart
│   └── game_over_screen.dart
└── widgets/
    ├── player.dart
    ├── enemy.dart
    └── bullet.dart
```

## Assets

The game uses fallback colored widgets if image assets are not found. To add custom sprites:

1. Create images in `assets/images/`:
   - `player.png` (50x50 recommended)
   - `enemy.png` (40x40 recommended)
   - `bullet.png` (5x15 recommended)

2. The game will automatically use them if present, otherwise uses colorful widget fallbacks.

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

- `shared_preferences: ^2.2.2` - For saving high scores and settings
- `audioplayers: ^5.2.1` - For sound effects and background music

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

### 🎁 Power-ups System (Ready for Integration)
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

## Future Enhancements

Potential improvements:
- Sound effects integration
- Background music
- Power-ups (multi-shot, shield, etc.)
- Boss enemies
- Leaderboard
- Achievement system
- Different difficulty modes

## License

This project is open source and available for educational purposes.
