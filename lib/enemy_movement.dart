import 'game_state.dart';

class EnemyMovementController {
  bool moveRight = true;
  bool shouldMoveDown = false;
  double screenWidth = 400;
  
  void updateEnemyMovement(List<Enemy> enemies, double screenWidth) {
    if (enemies.isEmpty) return;
    
    this.screenWidth = screenWidth;
    
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
    
    // Update enemy positions
    for (var enemy in enemies) {
      if (moveRight) {
        enemy.x += enemy.speed;
      } else {
        enemy.x -= enemy.speed;
      }
      
      if (shouldMoveDown) {
        enemy.y += 30;
      }
    }
  }
}

EnemyMovementController enemyController = EnemyMovementController();
