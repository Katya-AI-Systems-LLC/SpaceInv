import 'package:flutter_test/flutter_test.dart';
import 'package:space_invaders/game_over_conditions.dart';
import 'package:space_invaders/game_state.dart';

void main() {
  group('GameOverConditions.checkGameOver', () {
    test('returns true when player has no lives', () {
      final gameState = GameState();
      gameState.player.lives = 0;

      expect(GameOverConditions.checkGameOver(gameState), isTrue);
    });

    test('returns true when enemy reaches player line', () {
      final gameState = GameState();
      final enemy = gameState.enemies.first
        ..y = gameState.player.y
        ..height = gameState.player.height;

      expect(GameOverConditions.checkGameOver(gameState), isTrue);
      enemy.y = 0; // reset to avoid affecting other tests
    });

    test('returns false when game state is healthy', () {
      final gameState = GameState();
      expect(GameOverConditions.checkGameOver(gameState), isFalse);
    });
  });

  group('GameOverConditions.checkGameWon', () {
    test('returns true when all enemies defeated', () {
      final gameState = GameState();
      gameState.enemies.clear();
      expect(GameOverConditions.checkGameWon(gameState), isTrue);
    });

    test('returns false when enemies remain', () {
      final gameState = GameState();
      expect(GameOverConditions.checkGameWon(gameState), isFalse);
    });
  });

  group('GameOverConditions.checkPlayerHitByEnemy', () {
    test('detects collision with player', () {
      final gameState = GameState();
      final enemy = gameState.enemies.first
        ..x = gameState.player.x
        ..y = gameState.player.y
        ..width = gameState.player.width
        ..height = gameState.player.height;

      final hit = GameOverConditions.checkPlayerHitByEnemy(gameState);
      expect(hit, isTrue);
    });

    test('returns false when player invulnerable', () {
      final gameState = GameState();
      gameState.player.isInvulnerable = true;
      expect(GameOverConditions.checkPlayerHitByEnemy(gameState), isFalse);
    });
  });
}
