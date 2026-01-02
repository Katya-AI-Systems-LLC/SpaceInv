import 'package:flutter/material.dart';
import '../models/advanced_enemy.dart';

class AdvancedEnemyWidget extends StatelessWidget {
  final AdvancedEnemy enemy;
  final double time;
  
  const AdvancedEnemyWidget({
    super.key,
    required this.enemy,
    this.time = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!enemy.alive) return const SizedBox.shrink();
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main enemy body
        Container(
          width: enemy.width,
          height: enemy.height,
          decoration: BoxDecoration(
            color: enemy.color,
            borderRadius: _getBorderRadius(),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: enemy.color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: _buildEnemyIcon(),
          ),
        ),
        
        // Shield indicator
        if (enemy.isShielded)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: _getBorderRadius(),
                border: Border.all(
                  color: Colors.cyan,
                  width: 3,
                ),
              ),
            ),
          ),
        
        // Health bar for tanks and high-health enemies
        if (enemy.maxHealth > 3)
          Positioned(
            top: -8,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: enemy.health / enemy.maxHealth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        
        // Phase effect for phantoms
        if (enemy.isPhased)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: _getBorderRadius(),
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
          ),
      ],
    );
  }
  
  BorderRadius _getBorderRadius() {
    switch (enemy.type) {
      case AdvancedEnemyType.tank:
        return BorderRadius.circular(8);
      case AdvancedEnemyType.healer:
        return BorderRadius.circular(20);
      case AdvancedEnemyType.spawner:
        return BorderRadius.circular(12);
      case AdvancedEnemyType.phantom:
        return BorderRadius.circular(25);
      case AdvancedEnemyType.morphing:
        return BorderRadius.circular(15);
      case AdvancedEnemyType.teleporter:
        return BorderRadius.circular(30);
      default:
        return BorderRadius.circular(4);
    }
  }
  
  Widget _buildEnemyIcon() {
    switch (enemy.type) {
      case AdvancedEnemyType.sniper:
        return Icon(
          Icons.gps_fixed,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.tank:
        return Icon(
          Icons.security,
          color: Colors.white,
          size: enemy.width * 0.6,
        );
      case AdvancedEnemyType.healer:
        return Icon(
          Icons.healing,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.spawner:
        return Icon(
          Icons.pets,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.phantom:
        return Icon(
          Icons.blur_on,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.morphing:
        return Icon(
          Icons.change_circle,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.shielded:
        return Icon(
          Icons.shield,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
      case AdvancedEnemyType.teleporter:
        return Icon(
          Icons.flash_on,
          color: Colors.white,
          size: enemy.width * 0.5,
        );
    }
  }
}
