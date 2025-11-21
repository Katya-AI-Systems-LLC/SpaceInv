import 'package:flutter_test/flutter_test.dart';
import 'package:space_invaders/game_state.dart';

void main() {
  group('GameState Tests', () {
    test('GameState initializes correctly', () {
      final gameState = GameState();
      
      expect(gameState.score, 0);
      expect(gameState.level, 1);
      expect(gameState.gameOver, false);
      expect(gameState.isPaused, false);
      expect(gameState.player.lives, 3);
      expect(gameState.enemies.isNotEmpty, true);
    });

    test('Next level increases level and resets enemies', () {
      final gameState = GameState();
      final initialLevel = gameState.level;
      
      gameState.nextLevel();
      
      expect(gameState.level, initialLevel + 1);
      expect(gameState.enemies.isNotEmpty, true);
      expect(gameState.player.isInvulnerable, true);
    });

    test('Player invulnerability updates correctly', () {
      final player = Player();
      player.isInvulnerable = true;
      player.invulnerableTime = 2.0;
      
      player.updateInvulnerability(1.0);
      expect(player.isInvulnerable, true);
      expect(player.invulnerableTime, closeTo(1.0, 0.01));
      
      player.updateInvulnerability(1.5);
      expect(player.isInvulnerable, false);
      expect(player.invulnerableTime, lessThanOrEqualTo(0.0));
    });
  });

  group('Enemy Tests', () {
    test('Enemy initializes correctly', () {
      final enemy = Enemy(x: 100, y: 50, type: 0);
      
      expect(enemy.x, 100);
      expect(enemy.y, 50);
      expect(enemy.alive, true);
      expect(enemy.type, 0);
    });

    test('Fast enemy has higher speed', () {
      final normalEnemy = Enemy(x: 100, y: 50, type: 0);
      final fastEnemy = Enemy(x: 100, y: 50, type: 1);
      
      expect(fastEnemy.speed, greaterThan(normalEnemy.speed));
    });
  });

  group('Bullet Tests', () {
    test('Bullet moves correctly', () {
      final bullet = Bullet(x: 100, y: 100, isPlayerBullet: true);
      final initialY = bullet.y;
      
      bullet.move();
      
      expect(bullet.y, lessThan(initialY)); // Player bullets move up
    });

    test('Enemy bullet moves down', () {
      final bullet = Bullet(x: 100, y: 100, isPlayerBullet: false);
      final initialY = bullet.y;
      
      bullet.move();
      
      expect(bullet.y, greaterThan(initialY)); // Enemy bullets move down
    });
  });
}

