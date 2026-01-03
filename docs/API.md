# Space Invaders API Documentation

## 📚 Overview

This document provides comprehensive API documentation for the Space Invaders Enhanced Edition game engine. It covers all major systems, classes, and methods available for extension and customization.

## 🏗️ Architecture Overview

### Core Systems
- **Game State Management**: Central state management for all game entities
- **Weapon System**: Advanced weapon types and mechanics
- **Enemy System**: Regular and advanced enemy types
- **Power-Up System**: Enhanced power-ups with weighted spawning
- **Environmental Hazards**: Dynamic obstacles and effects
- **Special Abilities**: Player abilities with cooldowns
- **Audio System**: Sound effects and music management
- **UI System**: Widgets and visual components

### File Structure
```
lib/
├── models/           # Data models and game entities
├── screens/          # Game screens and UI pages
├── widgets/          # Reusable UI components
├── services/         # External services and utilities
└── game_state.dart   # Central game state management
```

---

## 🎮 Game State API

### GameState Class

The central class managing all game state and entities.

#### Properties

```dart
class GameState {
  // Player
  Player player;
  
  // Game Entities
  List<Enemy> enemies;
  List<AdvancedEnemy> advancedEnemies;
  List<Bullet> bullets;
  List<PowerUp> powerUps;
  List<EnvironmentalHazard> hazards;
  
  // Game State
  int score;
  int level;
  int lives;
  bool gameOver;
  bool isPaused;
  GameMode mode;
  
  // Advanced Systems
  double difficultyMultiplier;
  bool timeSlowed;
  double screenShakeDuration;
  double screenShakeIntensity;
  
  // Weapon System
  List<Weapon> availableWeapons;
  int currentWeaponIndex;
  Weapon get currentWeapon;
  
  // Special Abilities
  List<SpecialAbilityState> specialAbilities;
  
  // Power-Up System
  bool hasMultiShot;
  double multiShotTime;
  bool hasShield;
  double shieldTime;
  bool hasSpeedBoost;
  double speedBoostTime;
}
```

#### Methods

```dart
// Game Loop
void update(double deltaTime);
void initLevel();
void resetGame();

// Weapon Management
void switchWeapon(int direction);
void changeWeapon(Weapon weapon);
void updateWeapon(double deltaTime);

// Special Abilities
void useSpecialAbility(SpecialAbility ability);
void updateSpecialAbilities(double deltaTime);
void activateTimeSlow(double duration);
void clearScreen();

// Power-Ups
void spawnPowerUp(double x, double y);
void applyPowerUp(PowerUp powerUp);
void updatePowerUps(double deltaTime);

// Environmental Hazards
void spawnHazard();
void updateHazards(double deltaTime);
void clearHazards();

// Difficulty
void updateDifficulty();
void adjustDifficulty(double multiplier);

// Collision Detection
void checkCollisions();
bool checkPlayerCollision();
bool checkEnemyCollisions();
bool checkBulletCollisions();

// Scoring
void addScore(int points);
void updateCombo();
void resetCombo();

// Game State
void pauseGame();
void resumeGame();
void endGame();
```

---

## 🔫 Weapon System API

### Weapon Class

Represents different weapon types with unique properties.

#### Properties

```dart
class Weapon {
  final WeaponType type;
  final int level;
  final double damage;
  final double fireRate;
  final int projectileCount;
  final double spread;
  
  // Computed Properties
  String get name;
  Color get color;
}
```

#### Constructor Methods

```dart
// Factory Constructors
Weapon.basic()      // Basic cannon
Weapon.spread()    // Spread shot
Weapon.laser()     // Laser beam
Weapon.plasma()    // Plasma cannon
Weapon.rocket()    // Rocket launcher
Weapon.wave()      // Wave gun

// Custom Weapon
Weapon({
  required WeaponType type,
  this.level = 1,
  this.damage = 1.0,
  this.fireRate = 1.0,
  this.projectileCount = 1,
  this.spread = 0.0,
});
```

#### Methods

```dart
Weapon copyWith({
  WeaponType? type,
  int? level,
  double? damage,
  double? fireRate,
  int? projectileCount,
  double? spread,
});
```

### WeaponType Enum

```dart
enum WeaponType {
  basic,    // Standard cannon
  spread,   // Multi-directional
  laser,     // Piercing beam
  plasma,    // Dual projectiles
  rocket,    // High damage
  wave,      // Wave pattern
}
```

---

## ⚡ Special Abilities API

### SpecialAbilityState Class

Manages special ability state, cooldowns, and duration.

#### Properties

```dart
class SpecialAbilityState {
  final SpecialAbility type;
  double cooldown;
  double maxCooldown;
  bool isActive;
  double duration;
  double maxDuration;
  
  // Computed Properties
  bool get canUse;
  double get cooldownProgress;
  double get durationProgress;
  String get name;
  IconData get icon;
  Color get color;
}
```

#### Methods

```dart
void update(double deltaTime);
void activate();
```

### SpecialAbility Enum

```dart
enum SpecialAbility {
  timeSlow,     // Slows down enemies
  screenClear,  // Destroys all enemies
  megaShield,   // Temporary invulnerability
  rapidFire,    // Increased fire rate
}
```

---

## 👾 Advanced Enemy API

### AdvancedEnemy Class

Represents advanced enemy types with unique behaviors and abilities.

#### Properties

```dart
class AdvancedEnemy {
  double x, y;
  double width, height;
  double speed;
  int health, maxHealth;
  bool alive;
  AdvancedEnemyType type;
  
  // Ability System
  double abilityCooldown;
  double maxAbilityCooldown;
  double lastAbilityTime;
  
  // Special Properties
  double teleportCooldown;
  double shieldStrength;
  bool isShielded;
  bool isPhased;
  double phaseTime;
  
  // Movement
  List<Offset> movementPattern;
  int currentPatternIndex;
  
  // Computed Properties
  String get name;
  Color get color;
}
```

#### Methods

```dart
void update(double deltaTime, double screenWidth, double screenHeight);
void move(double deltaTime);
void useAbility();
bool canUseAbility();
void takeDamage(int damage);
```

### AdvancedEnemyType Enum

```dart
enum AdvancedEnemyType {
  sniper,     // Precise aimed shots
  tank,       // Heavy armor, slow
  healer,     // Heals nearby enemies
  spawner,    // Creates smaller enemies
  phantom,    // Temporary invulnerability
  morphing,   // Size changes
  shielded,   // Regenerating shields
  teleporter, // Teleportation
}
```

---

## 🌌 Environmental Hazards API

### EnvironmentalHazard Class

Represents environmental hazards that affect gameplay.

#### Properties

```dart
class EnvironmentalHazard {
  double x, y;
  double width, height;
  double speed;
  HazardType type;
  bool active;
  double lifetime;
  
  // Hazard-specific Properties
  double damage;
  double pullRadius;      // For black holes
  double expansionRadius;  // For solar flares
  
  // Computed Properties
  String get name;
  Color get color;
}
```

#### Methods

```dart
void update(double deltaTime);
void move(double deltaTime);
void affectPlayer(Player player);
void affectBullets(List<Bullet> bullets);
```

### HazardType Enum

```dart
enum HazardType {
  asteroid,     // Destructible obstacles
  spaceDebris,  // Small fast obstacles
  blackHole,    // Gravitational pull
  solarFlare,   // Expanding damage area
  comet,        // Fast projectiles
  nebula,       // Projectile interference
}
```

---

## 💎 Power-Ups API

### PowerUp Class

Represents collectible power-ups with various effects.

#### Properties

```dart
class PowerUp {
  double x, y;
  double width, height;
  double speed;
  PowerUpType type;
  bool active;
  
  // Computed Properties
  String get name;
  String get description;
  Color get color;
  IconData get icon;
}
```

#### Methods

```dart
void move();
static PowerUpType getRandomType();
```

### PowerUpType Enum

```dart
enum PowerUpType {
  multiShot,      // Multiple bullets
  shield,         // Temporary invulnerability
  speedBoost,     // Increased movement
  lifeUp,         // Extra life
  weaponUpgrade,  // Weapon enhancement
  energyBoost,    // Energy restoration
  timeBomb,       // Delayed screen clear
  magnet,         // Attract power-ups
  drone,          // Auto-firing assistant
  freeze,         // Freeze enemies
}
```

---

## 🎵 Audio System API

### AudioService Class

Manages all audio playback and effects.

#### Methods

```dart
// Initialization
Future<void> initialize();

// Sound Effects
void playShootSound();
void playExplosionSound();
void playPowerUpSound();
void playHitSound();
void playShieldSound();

// Music
void playBackgroundMusic();
void stopBackgroundMusic();
void pauseBackgroundMusic();
void resumeBackgroundMusic();

// Volume Control
void setMasterVolume(double volume);
void setSfxVolume(double volume);
void setMusicVolume(double volume);

// Audio State
bool get isInitialized;
double get masterVolume;
double get sfxVolume;
double get musicVolume;
```

---

## 🎨 UI System API

### Widget Classes

#### WeaponWidget
Displays weapon information and status.

```dart
WeaponWidget({
  required Weapon weapon,
  required bool isActive,
  required double energy,
});
```

#### SpecialAbilityWidget
Displays special ability with cooldown indicator.

```dart
SpecialAbilityWidget({
  required SpecialAbilityState ability,
});
```

#### AdvancedEnemyWidget
Renders advanced enemy with visual effects.

```dart
AdvancedEnemyWidget({
  required AdvancedEnemy enemy,
  required double time,
});
```

#### EnvironmentalHazardWidget
Renders environmental hazards with animations.

```dart
EnvironmentalHazardWidget({
  required EnvironmentalHazard hazard,
  required double time,
});
```

---

## 🎮 Game Modes API

### GameMode Enum

```dart
enum GameMode {
  classic,     // Original gameplay
  survival,    // Endless waves
  hardcore,    // One life only
  galacticRun, // Endless running
  bossRush,    // Boss battles only
}
```

### GameMode Properties

```dart
extension GameModeExtension on GameMode {
  String get label;
  String get description;
  IconData get icon;
  Color get color;
}
```

---

## 📊 Statistics API

### GameStats Class

Tracks player performance and statistics.

#### Properties

```dart
class GameStats {
  int totalScore;
  int highScore;
  int enemiesDestroyed;
  int powerUpsCollected;
  int shotsFired;
  int shotsHit;
  double accuracy;
  int playTime;
  int gamesPlayed;
  int gamesWon;
  
  // Advanced Stats
  int weaponSwitches;
  int abilitiesUsed;
  int perfectLevels;
  double averageAccuracy;
}
```

#### Methods

```dart
void updateStats();
void resetStats();
Map<String, dynamic> toJson();
static GameStats fromJson(Map<String, dynamic> json);
```

---

## 🔧 Utility APIs

### Vector2D Class
2D vector mathematics for game physics.

```dart
class Vector2D {
  double x, y;
  
  Vector2D(this.x, this.y);
  
  // Operations
  Vector2D operator +(Vector2D other);
  Vector2D operator -(Vector2D other);
  Vector2D operator *(double scalar);
  double magnitude();
  Vector2D normalize();
  double dot(Vector2D other);
}
```

### MathUtils
Utility functions for game calculations.

```dart
class MathUtils {
  static double distance(Offset a, Offset b);
  static double angle(Offset from, Offset to);
  static Offset lerp(Offset a, Offset b, double t);
  static bool circleCollision(Offset a, double r1, Offset b, double r2);
  static bool rectCollision(Rect a, Rect b);
  static Offset randomDirection();
  static double clamp(double value, double min, double max);
}
```

---

## 🎯 Usage Examples

### Creating Custom Weapon

```dart
class CustomWeapon extends Weapon {
  CustomWeapon() : super(
    type: WeaponType.basic,
    damage: 2.5,
    fireRate: 1.5,
    projectileCount: 2,
    spread: 15.0,
  );
  
  @override
  String get name => 'Dual Cannon';
  
  @override
  Color get color => Colors.purple;
}
```

### Adding New Enemy Type

```dart
enum AdvancedEnemyType {
  // ... existing types
  customEnemy,  // New type
}

class CustomEnemy extends AdvancedEnemy {
  CustomEnemy(double x, double y) : super(
    x: x,
    y: y,
    type: AdvancedEnemyType.customEnemy,
    health: 4,
    maxAbilityCooldown: 3.0,
  );
  
  @override
  void useAbility() {
    // Custom ability logic
    super.useAbility();
  }
}
```

### Creating Custom Power-Up

```dart
enum PowerUpType {
  // ... existing types
  customPowerUp,  // New type
}

class CustomPowerUp extends PowerUp {
  CustomPowerUp(double x, double y) : super(
    x: x,
    y: y,
    type: PowerUpType.customPowerUp,
  );
  
  @override
  String get name => 'Custom Power';
  
  @override
  Color get color => Colors.teal;
}
```

---

## 📝 Development Guidelines

### Performance Considerations
- Maintain 60 FPS target
- Use object pooling for bullets and particles
- Optimize collision detection algorithms
- Implement efficient rendering with dirty flags

### Memory Management
- Dispose of unused resources
- Use weak references where appropriate
- Implement proper cleanup in dispose methods
- Monitor memory usage during gameplay

### Testing
- Write unit tests for all game logic
- Create widget tests for UI components
- Implement integration tests for game flow
- Test on multiple platforms and devices

---

## 🔍 Debugging Tools

### Game State Inspector
```dart
// Debug game state
void debugGameState() {
  print('Player: ${gameState.player.position}');
  print('Enemies: ${gameState.enemies.length}');
  print('Score: ${gameState.score}');
}
```

### Performance Monitor
```dart
// Monitor frame rate
void monitorPerformance() {
  final stopwatch = Stopwatch()..start();
  // Game update logic
  stopwatch.stop();
  print('Frame time: ${stopwatch.elapsedMilliseconds}ms');
}
```

---

**Last Updated**: January 3, 2024
**API Version**: 2.0.0
**Compatible with**: Space Invaders Enhanced Edition v2.0.0+
