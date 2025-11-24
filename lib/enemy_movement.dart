import 'dart:math' as math;

import 'game_state.dart';
import 'models/game_mode.dart';

class EnemyMovementController {
  bool moveRight = true;
  bool shouldMoveDown = false;
  double screenWidth = 400;
  double _time = 0;
  GameMode _mode = GameMode.classic;
  
  void updateEnemyMovement(List<Enemy> enemies, double screenWidth, GameMode mode) {
    if (enemies.isEmpty) return;
    
    this.screenWidth = screenWidth;
    _mode = mode;
    _time += 0.12;
    
    // Find rightmost and leftmost enemies
    double rightmostX = -1;
    double leftmostX = double.infinity;
    
    for (var enemy in enemies) {
      if (enemy.x + enemy.width > rightmostX) {
        rightmostX = enemy.x + enemy.width;
      }
      if (enemy.x < leftmostX) {
        leftmostX = enemy.x;
      }
    }
    
    // Check if enemies should change direction
    shouldMoveDown = false;
    if (moveRight && rightmostX >= screenWidth - 10) {
      moveRight = false;
      shouldMoveDown = true;
    } else if (!moveRight && leftmostX <= 10) {
      moveRight = true;
      shouldMoveDown = true;
    }
    
    // Update enemy positions (baseline formation movement)
    for (var enemy in enemies) {
      // Kamikaze enemies move independently, skip baseline movement
      if (enemy.type == 4 && !enemy.isBoss) {
        continue;
      }
      if (moveRight) {
        enemy.x += enemy.speed;
      } else {
        enemy.x -= enemy.speed;
      }
      
      if (shouldMoveDown) {
        enemy.y += 30;
      }
    }

    // Apply additional patterns per enemy type/mode
    double fastWaveAmplitude;
    double bossBobAmplitude;

    switch (_mode) {
      case GameMode.classic:
        fastWaveAmplitude = 0.4;
        bossBobAmplitude = 0.5;
        break;
      case GameMode.survival:
        fastWaveAmplitude = 0.7;
        bossBobAmplitude = 0.8;
        break;
      case GameMode.hardcore:
        fastWaveAmplitude = 1.0;
        bossBobAmplitude = 1.1;
        break;
      case GameMode.galacticRun:
        fastWaveAmplitude = 0.8;
        bossBobAmplitude = 0.9;
        break;
      case GameMode.bossRush:
        fastWaveAmplitude = 0.6;
        bossBobAmplitude = 1.2;
        break;
    }

    for (var enemy in enemies) {
      // Fast enemies move in a slight wave pattern
      if (enemy.type == 1 && fastWaveAmplitude > 0) {
        enemy.y += math.sin(_time + enemy.x * 0.05) * fastWaveAmplitude;
      }

      // Boss enemies bob up and down a bit for a more dynamic feel
      if (enemy.isBoss && bossBobAmplitude > 0) {
        enemy.y += math.sin(_time * 0.8) * bossBobAmplitude;
      }

      // Kamikaze enemies dive toward the bottom with a zig-zag pattern
      if (enemy.type == 4 && !enemy.isBoss) {
        double diveSpeed = enemy.speed * 1.5;
        if (_mode == GameMode.survival) {
          diveSpeed *= 1.1;
        } else if (_mode == GameMode.hardcore) {
          diveSpeed *= 1.25;
        }

        enemy.y += diveSpeed;
        enemy.x += math.sin(_time + enemy.y * 0.05) * 2.5;
      }
    }
  }
}

EnemyMovementController enemyController = EnemyMovementController();
