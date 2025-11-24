import 'game_state.dart';

/// Checks for game over conditions in the game
class GameOverConditions {
  /// Checks if the game should end based on various conditions
  /// Returns true if game over conditions are met
  static bool checkGameOver(GameState gameState) {
    // Game over if player has no lives left
    if (gameState.player.lives <= 0) {
      return true;
    }
    
    // Game over if any enemy reaches the player's y position
    for (var enemy in gameState.enemies) {
      if (enemy.alive && enemy.y + enemy.height >= gameState.player.y) {
        return true;
      }
    }
    
    // Game over if gameOver flag is set
    if (gameState.gameOver) {
      return true;
    }
    
    return false;
  }
  
  /// Checks if the player has won the game
  /// Returns true if all enemies are defeated
  static bool checkGameWon(GameState gameState) {
    // Game won if all enemies are defeated
    return gameState.enemies.isEmpty && !gameState.gameOver;
  }
  
  /// Checks if the game should end due to player being hit by enemy
  /// This is a specific game over condition
  static bool checkPlayerHitByEnemy(GameState gameState) {
    if (gameState.player.isInvulnerable) {
      return false;
    }
    
    // Check if any enemy collides with player
    for (var enemy in gameState.enemies) {
      if (enemy.alive) {
        // Check collision between enemy and player
        if (enemy.x < gameState.player.x + gameState.player.width &&
            enemy.x + enemy.width > gameState.player.x &&
            enemy.y < gameState.player.y + gameState.player.height &&
            enemy.y + enemy.height > gameState.player.y) {
          return true;
        }
      }
    }
    
    return false;
  }
}

