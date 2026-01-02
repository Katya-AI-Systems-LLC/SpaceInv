import 'dart:math' as math;

import 'models/power_up.dart';
import 'models/game_mode.dart';
import 'models/barrier.dart';
import 'models/run_modifier.dart';
import 'models/weapon.dart';
import 'models/advanced_enemy.dart';
import 'models/environmental_hazard.dart';
import 'services/upgrades_service.dart';
import 'models/upgrade_type.dart';

class Player {
  double x = 200;
  double y = 500;
  double speed = 5;
  double width = 50;
  double height = 50;
  int lives = 3;
  bool isInvulnerable = false;
  double invulnerableTime = 0;
  Weapon currentWeapon = Weapon.basic();
  List<SpecialAbilityState> specialAbilities = [];
  int weaponEnergy = 100;
  double lastFireTime = 0;
  double fireRate = 0.2;
  
  Player() {
    // Initialize special abilities
    specialAbilities = [
      SpecialAbilityState(type: SpecialAbility.timeSlow, maxCooldown: 45),
      SpecialAbilityState(type: SpecialAbility.screenClear, maxCooldown: 60),
      SpecialAbilityState(type: SpecialAbility.megaShield, maxCooldown: 30),
      SpecialAbilityState(type: SpecialAbility.rapidFire, maxCooldown: 25),
    ];
  }
  
  void updateWeapon(double deltaTime) {
    if (weaponEnergy < 100) {
      weaponEnergy += (deltaTime * 5).round(); // Regenerate energy
      weaponEnergy = weaponEnergy.clamp(0, 100);
    }
  }
  
  void updateSpecialAbilities(double deltaTime) {
    for (var ability in specialAbilities) {
      ability.update(deltaTime);
    }
  }
  
  bool canFire() {
    return (DateTime.now().millisecondsSinceEpoch / 1000.0) - lastFireTime >= fireRate;
  }
  
  void fire() {
    lastFireTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
  }
  
  void useSpecialAbility(SpecialAbility type) {
    final ability = specialAbilities.firstWhere((a) => a.type == type);
    ability.activate();
  }
  
  void changeWeapon(Weapon newWeapon) {
    currentWeapon = newWeapon;
    fireRate = 0.2 / newWeapon.fireRate;
  }
  
  void updateInvulnerability(double deltaTime) {
    if (isInvulnerable) {
      invulnerableTime -= deltaTime;
      if (invulnerableTime <= 0) {
        isInvulnerable = false;
      }
    }
  }
}

class Enemy {
  double x;
  double y;
  double speed = 1;
  double width = 40;
  double height = 40;
  bool alive = true;
  int type = 0; // 0 = normal, 1 = fast, 2 = strong, 3 = boss, 4 = kamikaze
  int health;
  bool isBoss;
  
  Enemy({
    required this.x,
    required this.y,
    this.type = 0,
    this.health = 1,
    this.isBoss = false,
    double? width,
    double? height,
  })  : width = width ?? 40,
        height = height ?? 40 {
    if (type == 1) speed = 1.5;
    if (type == 2) speed = 0.8;
    if (type == 4) speed = 1.8;
    if (type == 3 || isBoss) {
      speed = 1.2;
      isBoss = true;
    }
  }
}

class Bullet {
  double x;
  double y;
  double speed = 10;
  double width = 5;
  double height = 15;
  bool isPlayerBullet = true;

  Bullet({required this.x, required this.y, this.isPlayerBullet = true});

  void move() {
    if (isPlayerBullet) {
      y -= speed;
    } else {
      y += speed;
    }
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  int life;
  double size;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.life = 30,
    this.size = 3,
  });
  
  void update() {
    x += vx;
    y += vy;
    life--;
  }
}

class GameState {
  Player player = Player();
  List<Enemy> enemies = [];
  List<AdvancedEnemy> advancedEnemies = [];
  List<Bullet> bullets = [];
  List<Bullet> enemyBullets = [];
  List<Particle> particles = [];
  List<PowerUp> powerUps = [];
  List<Barrier> barriers = [];
  List<EnvironmentalHazard> hazards = [];
  HazardManager hazardManager = HazardManager();
  int score = 0;
  int level = 1;
  bool gameOver = false;
  bool isPaused = false;
  bool gameWon = false;
  double lastEnemyShootTime = 0;
  double gameTime = 0;
  int enemiesKilled = 0; // Track killed enemies for statistics
  double multiShotTime = 0;
  double speedBoostTime = 0;
  final GameMode mode;
  RunModifier? currentModifier;
  final math.Random _random = math.Random();
  int bossMaxHealth = 0;
  int comboCount = 0;
  double comboTimeRemaining = 0;
  int comboMultiplier = 1;
  
  // Dynamic difficulty
  double difficultyMultiplier = 1.0;
  int playerPerformanceScore = 0;
  double lastDifficultyAdjust = 0;
  
  // Special effects
  bool timeSlowed = false;
  double timeSlowDuration = 0;
  double screenShakeIntensity = 0;
  double screenShakeDuration = 0;
  
  // Weapon system
  List<Weapon> availableWeapons = [
    Weapon.basic(),
    Weapon.spread(),
    Weapon.laser(),
    Weapon.plasma(),
    Weapon.rocket(),
    Weapon.wave(),
  ];
  int currentWeaponIndex = 0;

  bool get hasMultiShot => multiShotTime > 0;
  bool get hasSpeedBoost => speedBoostTime > 0;
  bool get hasCombo => comboMultiplier > 1 && comboTimeRemaining > 0;

  GameState({this.mode = GameMode.classic}) {
    // Initial player setup based on mode and upgrades
    final upgrades = UpgradesService();
    final extraLivesLevel = upgrades.getLevel(UpgradeType.extraLife);
    int baseLives = mode == GameMode.hardcore ? 1 : 3;
    int totalLives = baseLives + extraLivesLevel;
    if (totalLives > 5) {
      totalLives = 5;
    }
    player.lives = totalLives;
    initLevel();
  }
  
  void initLevel() {
    enemies.clear();
    advancedEnemies.clear();
    bullets.clear();
    enemyBullets.clear();
    particles.clear();
    powerUps.clear();
    barriers.clear();
    hazards.clear();
    hazardManager.clear();
    multiShotTime = 0;
    speedBoostTime = 0;
    player.speed = 5;
    player.isInvulnerable = false;
    
    final upgrades = UpgradesService();
    final startingLevel = upgrades.getLevel(UpgradeType.startingPower);
    if (startingLevel >= 1) {
      multiShotTime = 4.0;
    }
    if (startingLevel >= 2) {
      player.isInvulnerable = true;
      player.invulnerableTime = 2.0;
    }
    
    // Select a new modifier for Galactic Run, clear otherwise
    if (mode == GameMode.galacticRun) {
      currentModifier = RunModifier.values[_random.nextInt(RunModifier.values.length)];
    } else {
      currentModifier = null;
    }
    
    // Initialize barriers near the bottom of the playfield
    if (mode != GameMode.hardcore) {
      // Simple 3-shield layout; coordinates are tuned for ~400px-wide playfield
      barriers.addAll([
        Barrier(x: 60, y: 400),
        Barrier(x: 170, y: 400),
        Barrier(x: 280, y: 400),
      ]);

      final shieldLevel = upgrades.getLevel(UpgradeType.shieldStrength);
      if (shieldLevel > 0) {
        for (final barrier in barriers) {
          barrier.health += shieldLevel * 2;
        }
      }
    }

    // Boss-only waves in Boss Rush mode
    if (mode == GameMode.bossRush) {
      final int baseHealth = 30 + level * 10;
      bossMaxHealth = baseHealth;
      enemies.add(Enemy(
        x: 80,
        y: 60,
        type: 3,
        width: 140 + level * 5,
        height: 70 + level * 3,
        health: baseHealth,
        isBoss: true,
      )..speed = 1.5 + level * 0.1);
      return;
    }

    if (level % 5 == 0 && mode == GameMode.classic) {
      final int baseHealth = 20 + level * 2;
      bossMaxHealth = baseHealth;
      enemies.add(Enemy(
        x: 80,
        y: 60,
        type: 3,
        width: 140,
        height: 70,
        health: baseHealth,
        isBoss: true,
      )..speed = 1.5);
    } else {
      // Initialize enemies in a grid
      int enemyRows = 3 + (level ~/ 2);
      int enemyCols = 8 + (level ~/ 3);
      
      for (int row = 0; row < enemyRows; row++) {
        for (int col = 0; col < enemyCols; col++) {
          int type = 0;
          if (row == 0 && (col % 3 == 0)) type = 1; // Fast enemies
          if (row == enemyRows - 1 && (col % 4 == 0)) type = 2; // Strong enemies
          if (level >= 4 && row == 1 && (col % 5 == 0)) type = 4; // Kamikaze divers

          if (mode == GameMode.galacticRun && currentModifier == RunModifier.kamikazeSwarm) {
            if (row == 1 && (col % 3 == 0)) {
              type = 4;
            }
          }
          
          double baseSpeed = 1 + level * 0.2;
          if (mode == GameMode.survival) {
            baseSpeed += 0.4;
          } else if (mode == GameMode.hardcore) {
            baseSpeed += 0.7;
          }
          if (mode == GameMode.galacticRun && currentModifier == RunModifier.fastEnemies) {
            baseSpeed += 0.6;
          }

          enemies.add(Enemy(
            x: col * 45.0 + 30,
            y: row * 45.0 + 50,
            type: type,
          )..speed = baseSpeed);
        }
      }
      
      // Add advanced enemies based on level
      if (level >= 3) {
        _addAdvancedEnemies();
      }
    }
  }
  
  void _addAdvancedEnemies() {
    final advancedCount = math.min(level ~/ 2, 5);
    for (int i = 0; i < advancedCount; i++) {
      final types = AdvancedEnemyType.values;
      final type = types[_random.nextInt(types.length)];
      final x = _random.nextDouble() * 300 + 50;
      final y = _random.nextDouble() * 100 + 50;
      
      switch (type) {
        case AdvancedEnemyType.sniper:
          advancedEnemies.add(AdvancedEnemy.sniper(x, y));
          break;
        case AdvancedEnemyType.tank:
          advancedEnemies.add(AdvancedEnemy.tank(x, y));
          break;
        case AdvancedEnemyType.healer:
          advancedEnemies.add(AdvancedEnemy.healer(x, y));
          break;
        case AdvancedEnemyType.spawner:
          advancedEnemies.add(AdvancedEnemy.spawner(x, y));
          break;
        case AdvancedEnemyType.phantom:
          advancedEnemies.add(AdvancedEnemy.phantom(x, y));
          break;
        case AdvancedEnemyType.morphing:
          advancedEnemies.add(AdvancedEnemy.morphing(x, y));
          break;
        case AdvancedEnemyType.shielded:
          advancedEnemies.add(AdvancedEnemy.shielded(x, y));
          break;
        case AdvancedEnemyType.teleporter:
          advancedEnemies.add(AdvancedEnemy.teleporter(x, y));
          break;
      }
    }
  }
  
  void nextLevel() {
    level++;
    player.x = 200;
    player.isInvulnerable = true;
    player.invulnerableTime = 2.0;
    initLevel();
  }

  void updateCombo(double deltaTime) {
    if (comboTimeRemaining > 0) {
      comboTimeRemaining -= deltaTime;
      if (comboTimeRemaining <= 0) {
        comboTimeRemaining = 0;
        comboMultiplier = 1;
        comboCount = 0;
      }
    }
  }
  
  void updateDynamicDifficulty(double deltaTime) {
    lastDifficultyAdjust += deltaTime;
    
    // Adjust difficulty every 10 seconds
    if (lastDifficultyAdjust >= 10.0) {
      lastDifficultyAdjust = 0;
      
      // Calculate performance score
      double hitRate = enemiesKilled > 0 ? (enemiesKilled / (enemiesKilled + player.lives * 10)) : 0;
      double scoreRate = score / (gameTime + 1);
      
      playerPerformanceScore = (hitRate * 50 + scoreRate * 0.1).round();
      
      // Adjust difficulty based on performance
      if (playerPerformanceScore > 70) {
        difficultyMultiplier = math.min(difficultyMultiplier + 0.1, 2.0);
      } else if (playerPerformanceScore < 30) {
        difficultyMultiplier = math.max(difficultyMultiplier - 0.1, 0.5);
      }
    }
  }
  
  void updateSpecialEffects(double deltaTime) {
    // Update time slow
    if (timeSlowed && timeSlowDuration > 0) {
      timeSlowDuration -= deltaTime;
      if (timeSlowDuration <= 0) {
        timeSlowed = false;
        timeSlowDuration = 0;
      }
    }
    
    // Update screen shake
    if (screenShakeDuration > 0) {
      screenShakeDuration -= deltaTime;
      if (screenShakeDuration <= 0) {
        screenShakeDuration = 0;
        screenShakeIntensity = 0;
      }
    }
  }
  
  void addScreenShake(double intensity, double duration) {
    screenShakeIntensity = math.max(screenShakeIntensity, intensity);
    screenShakeDuration = math.max(screenShakeDuration, duration);
  }
  
  void activateTimeSlow(double duration) {
    timeSlowed = true;
    timeSlowDuration = duration;
  }
  
  void switchWeapon(int direction) {
    currentWeaponIndex = (currentWeaponIndex + direction) % availableWeapons.length;
    if (currentWeaponIndex < 0) currentWeaponIndex = availableWeapons.length - 1;
    player.changeWeapon(availableWeapons[currentWeaponIndex]);
  }
  
  void clearScreen() {
    // Destroy all regular enemies
    for (var enemy in enemies) {
      enemy.alive = false;
      score += 10;
      enemiesKilled++;
    }
    
    // Destroy all advanced enemies
    for (var enemy in advancedEnemies) {
      enemy.alive = false;
      score += enemy.points;
      enemiesKilled++;
    }
    
    // Clear enemy bullets
    enemyBullets.clear();
    
    // Add screen effects
    addScreenShake(15, 0.5);
    
    // Create explosion particles
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 300,
        vx: (_random.nextDouble() - 0.5) * 10,
        vy: (_random.nextDouble() - 0.5) * 10,
        life: 60,
        size: _random.nextDouble() * 5 + 2,
      ));
    }
  }
}
