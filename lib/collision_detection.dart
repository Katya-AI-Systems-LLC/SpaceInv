import 'dart:math' as math;
import 'game_state.dart';
import 'services/audio_service.dart';

bool checkRectCollision(
  double x1, double y1, double w1, double h1,
  double x2, double y2, double w2, double h2,
) {
  return x1 < x2 + w2 && x1 + w1 > x2 && y1 < y2 + h2 && y1 + h1 > y2;
}

void checkCollisions(
  GameState gameState, {
  AudioService? audioService,
  void Function(Enemy enemy)? onEnemyDestroyed,
}) {
  // Player bullets vs enemies
  gameState.bullets.removeWhere((bullet) {
    bool shouldRemove = false;
    
    // Player bullets vs barriers
    for (var barrier in gameState.barriers.toList()) {
      if (checkRectCollision(
        bullet.x,
        bullet.y,
        bullet.width,
        bullet.height,
        barrier.x,
        barrier.y,
        barrier.width,
        barrier.height,
      )) {
        barrier.health--;
        if (barrier.health <= 0) {
          gameState.barriers.remove(barrier);
        }
        shouldRemove = true;
        break;
      }
    }

    if (shouldRemove) {
      return true;
    }

    for (var enemy in gameState.enemies.toList()) {
      if (enemy.alive && checkRectCollision(
        bullet.x, bullet.y, bullet.width, bullet.height,
        enemy.x, enemy.y, enemy.width, enemy.height,
      )) {
        bool enemyDestroyed = true;
        if (enemy.health > 1) {
          enemy.health--;
          enemyDestroyed = false;
        }
        
        if (enemyDestroyed) {
          enemy.alive = false;
          gameState.enemies.remove(enemy);
          
          int points = 10;
          if (enemy.type == 1) points = 20; // Fast enemy
          if (enemy.type == 2) points = 15; // Strong enemy
          if (enemy.type == 4) points = 30; // Kamikaze
          if (enemy.isBoss || enemy.type == 3) points = 200;

          // Combo system: quick consecutive kills increase multiplier
          const double comboWindow = 2.0;
          if (gameState.comboTimeRemaining > 0) {
            gameState.comboCount++;
          } else {
            gameState.comboCount = 1;
          }
          gameState.comboTimeRemaining = comboWindow;

          int newMultiplier = 1;
          if (gameState.comboCount >= 3 && gameState.comboCount < 6) {
            newMultiplier = 2;
          } else if (gameState.comboCount >= 6 && gameState.comboCount < 10) {
            newMultiplier = 3;
          } else if (gameState.comboCount >= 10 && gameState.comboCount < 15) {
            newMultiplier = 4;
          } else if (gameState.comboCount >= 15) {
            newMultiplier = 5;
          }
          gameState.comboMultiplier = newMultiplier;

          final int totalPoints = points * gameState.comboMultiplier;
          gameState.score += totalPoints;
          gameState.enemiesKilled++; // Track killed enemies
          onEnemyDestroyed?.call(enemy);
        }
        
        createExplosion(
          gameState,
          enemy.x + enemy.width / 2,
          enemy.y + enemy.height / 2,
        );
        audioService?.playExplosionSound();
        shouldRemove = true;
        break;
      }
    }
    
    return shouldRemove;
  });
  
  // Enemy bullets vs player
  gameState.enemyBullets.removeWhere((bullet) {
    // Enemy bullets vs barriers
    for (var barrier in gameState.barriers.toList()) {
      if (checkRectCollision(
        bullet.x,
        bullet.y,
        bullet.width,
        bullet.height,
        barrier.x,
        barrier.y,
        barrier.width,
        barrier.height,
      )) {
        barrier.health--;
        if (barrier.health <= 0) {
          gameState.barriers.remove(barrier);
        }
        return true;
      }
    }

    if (!gameState.player.isInvulnerable && checkRectCollision(
      bullet.x, bullet.y, bullet.width, bullet.height,
      gameState.player.x, gameState.player.y,
      gameState.player.width, gameState.player.height,
    )) {
      gameState.player.lives--;
      gameState.player.isInvulnerable = true;
      gameState.player.invulnerableTime = 2.0;
      
      createExplosion(
        gameState,
        gameState.player.x + gameState.player.width / 2,
        gameState.player.y + gameState.player.height / 2,
      );
      audioService?.playExplosionSound();
      
      if (gameState.player.lives <= 0) {
        gameState.gameOver = true;
      }
      
      return true;
    }
    return false;
  });
  
  // Enemies vs player
  if (!gameState.player.isInvulnerable) {
    for (var enemy in gameState.enemies) {
      if (enemy.alive && checkRectCollision(
        enemy.x, enemy.y, enemy.width, enemy.height,
        gameState.player.x, gameState.player.y,
        gameState.player.width, gameState.player.height,
      )) {
        gameState.player.lives--;
        gameState.player.isInvulnerable = true;
        gameState.player.invulnerableTime = 2.0;
        gameState.comboTimeRemaining = 0;
        gameState.comboMultiplier = 1;
        gameState.comboCount = 0;
        
        if (gameState.player.lives <= 0) {
          gameState.gameOver = true;
        }
        audioService?.playExplosionSound();
        break;
      }
    }
  }
}

void createExplosion(GameState gameState, double x, double y) {
  for (int i = 0; i < 15; i++) {
    double angle = (math.pi * 2 / 15) * i;
    gameState.particles.add(Particle(
      x: x,
      y: y,
      vx: math.cos(angle) * 3,
      vy: math.sin(angle) * 3,
      life: 30,
      size: 4,
    ));
  }
}
