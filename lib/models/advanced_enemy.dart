import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AdvancedEnemyType {
  sniper,
  tank,
  healer,
  spawner,
  phantom,
  morphing,
  shielded,
  teleporter,
}

class AdvancedEnemy {
  double x;
  double y;
  double width;
  double height;
  double speed;
  int health;
  int maxHealth;
  final AdvancedEnemyType type;
  bool alive;
  double abilityCooldown;
  double maxAbilityCooldown;
  double lastAbilityTime;
  List<double> movementPattern;
  int currentPatternIndex;
  double teleportCooldown;
  double shieldStrength;
  bool isShielded;
  bool isPhased;
  double phaseTime;
  
  AdvancedEnemy({
    required this.x,
    required this.y,
    this.type = AdvancedEnemyType.sniper,
    this.width = 40,
    this.height = 40,
    this.speed = 1.0,
    this.health = 3,
    this.maxHealth = 3,
    this.alive = true,
    this.abilityCooldown = 0,
    this.maxAbilityCooldown = 5.0,
    this.lastAbilityTime = 0,
    this.movementPattern = const [],
    this.currentPatternIndex = 0,
    this.teleportCooldown = 0,
    this.shieldStrength = 0,
    this.isShielded = false,
    this.isPhased = false,
    this.phaseTime = 0,
  });

  factory AdvancedEnemy.sniper(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.sniper,
      width: 35,
      height: 45,
      speed: 0.8,
      health: 2,
      maxHealth: 2,
      maxAbilityCooldown: 3.0,
    );
  }

  factory AdvancedEnemy.tank(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.tank,
      width: 60,
      height: 60,
      speed: 0.5,
      health: 5,
      maxHealth: 5,
      maxAbilityCooldown: 8.0,
      isShielded: true,
      shieldStrength: 2,
    );
  }

  factory AdvancedEnemy.healer(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.healer,
      width: 45,
      height: 45,
      speed: 1.2,
      health: 3,
      maxHealth: 3,
      maxAbilityCooldown: 4.0,
    );
  }

  factory AdvancedEnemy.spawner(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.spawner,
      width: 55,
      height: 55,
      speed: 0.6,
      health: 4,
      maxHealth: 4,
      maxAbilityCooldown: 6.0,
    );
  }

  factory AdvancedEnemy.phantom(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.phantom,
      width: 40,
      height: 40,
      speed: 1.5,
      health: 2,
      maxHealth: 2,
      maxAbilityCooldown: 2.5,
    );
  }

  factory AdvancedEnemy.morphing(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.morphing,
      width: 45,
      height: 45,
      speed: 1.0,
      health: 3,
      maxHealth: 3,
      maxAbilityCooldown: 4.0,
    );
  }

  factory AdvancedEnemy.shielded(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.shielded,
      width: 50,
      height: 50,
      speed: 0.9,
      health: 4,
      maxHealth: 4,
      maxAbilityCooldown: 7.0,
      isShielded: true,
      shieldStrength: 3,
    );
  }

  factory AdvancedEnemy.teleporter(double x, double y) {
    return AdvancedEnemy(
      x: x,
      y: y,
      type: AdvancedEnemyType.teleporter,
      width: 40,
      height: 40,
      speed: 1.3,
      health: 3,
      maxHealth: 3,
      maxAbilityCooldown: 3.5,
      teleportCooldown: 4.0,
    );
  }

  void update(double deltaTime, double screenWidth, double screenHeight) {
    // Update ability cooldown
    if (abilityCooldown > 0) {
      abilityCooldown -= deltaTime;
    }
    
    // Update teleport cooldown
    if (teleportCooldown > 0) {
      teleportCooldown -= deltaTime;
    }
    
    // Update phase time
    if (isPhased && phaseTime > 0) {
      phaseTime -= deltaTime;
      if (phaseTime <= 0) {
        isPhased = false;
      }
    }
    
    // Movement patterns based on type
    switch (type) {
      case AdvancedEnemyType.sniper:
        // Snipers stay at distance and move horizontally
        x += math.sin(lastAbilityTime * 2) * speed;
        break;
      case AdvancedEnemyType.tank:
        // Tanks move slowly forward
        y += speed * 0.5;
        break;
      case AdvancedEnemyType.healer:
        // Healers circle around
        final angle = lastAbilityTime * 1.5;
        x += math.cos(angle) * speed;
        y += math.sin(angle) * speed * 0.5;
        break;
      case AdvancedEnemyType.spawner:
        // Spawners move in zigzag
        x += math.sin(lastAbilityTime * 3) * speed * 2;
        y += speed * 0.3;
        break;
      case AdvancedEnemyType.phantom:
        // Phantoms move erratically
        x += (math.Random().nextDouble() - 0.5) * speed * 3;
        y += speed * 0.7;
        break;
      case AdvancedEnemyType.morphing:
        // Morphing enemies change size
        final scale = 1.0 + math.sin(lastAbilityTime * 4) * 0.2;
        width = 45 * scale;
        height = 45 * scale;
        y += speed * 0.4;
        break;
      case AdvancedEnemyType.shielded:
        // Shielded enemies move deliberately
        x += math.sin(lastAbilityTime) * speed;
        y += speed * 0.6;
        break;
      case AdvancedEnemyType.teleporter:
        // Teleporters move then teleport
        if (teleportCooldown <= 0) {
          // Teleport to new position
          x = math.Random().nextDouble() * (screenWidth - width);
          y += math.Random().nextDouble() * 50;
          teleportCooldown = 4.0;
        } else {
          y += speed * 0.8;
        }
        break;
    }
    
    // Keep within bounds
    x = x.clamp(0.0, screenWidth - width);
    y = y.clamp(0.0, screenHeight - height);
    
    lastAbilityTime += deltaTime;
  }

  bool canUseAbility() {
    return abilityCooldown <= 0;
  }

  void useAbility() {
    abilityCooldown = maxAbilityCooldown;
    
    switch (type) {
      case AdvancedEnemyType.phantom:
        isPhased = true;
        phaseTime = 2.0;
        break;
      case AdvancedEnemyType.shielded:
        if (!isShielded) {
          isShielded = true;
          shieldStrength = 3;
        }
        break;
      case AdvancedEnemyType.sniper:
      case AdvancedEnemyType.tank:
      case AdvancedEnemyType.healer:
      case AdvancedEnemyType.spawner:
      case AdvancedEnemyType.morphing:
      case AdvancedEnemyType.teleporter:
        // Other enemies use default behavior
        break;
    }
  }

  void takeDamage(int damage) {
    if (isPhased) return; // Phased enemies can't be hit
    
    if (isShielded && shieldStrength > 0) {
      shieldStrength -= damage;
      if (shieldStrength <= 0) {
        isShielded = false;
        shieldStrength = 0;
      }
    } else {
      health -= damage;
      if (health <= 0) {
        alive = false;
      }
    }
  }

  Color get color {
    switch (type) {
      case AdvancedEnemyType.sniper:
        return Colors.red[700]!;
      case AdvancedEnemyType.tank:
        return Colors.grey[700]!;
      case AdvancedEnemyType.healer:
        return Colors.green[600]!;
      case AdvancedEnemyType.spawner:
        return Colors.purple[600]!;
      case AdvancedEnemyType.phantom:
        return Colors.blue[400]!.withOpacity(isPhased ? 0.5 : 1.0);
      case AdvancedEnemyType.morphing:
        return Colors.orange[600]!;
      case AdvancedEnemyType.shielded:
        return Colors.cyan[600]!;
      case AdvancedEnemyType.teleporter:
        return Colors.pink[600]!;
    }
  }

  String get name {
    switch (type) {
      case AdvancedEnemyType.sniper:
        return 'Sniper';
      case AdvancedEnemyType.tank:
        return 'Tank';
      case AdvancedEnemyType.healer:
        return 'Healer';
      case AdvancedEnemyType.spawner:
        return 'Spawner';
      case AdvancedEnemyType.phantom:
        return 'Phantom';
      case AdvancedEnemyType.morphing:
        return 'Morpher';
      case AdvancedEnemyType.shielded:
        return 'Shielded';
      case AdvancedEnemyType.teleporter:
        return 'Teleporter';
    }
  }

  int get points {
    switch (type) {
      case AdvancedEnemyType.sniper:
        return 25;
      case AdvancedEnemyType.tank:
        return 40;
      case AdvancedEnemyType.healer:
        return 30;
      case AdvancedEnemyType.spawner:
        return 35;
      case AdvancedEnemyType.phantom:
        return 45;
      case AdvancedEnemyType.morphing:
        return 30;
      case AdvancedEnemyType.shielded:
        return 35;
      case AdvancedEnemyType.teleporter:
        return 40;
    }
  }
}
