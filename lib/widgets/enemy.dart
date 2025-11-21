import 'package:flutter/material.dart';
import '../game_state.dart';

class EnemyWidget extends StatelessWidget {
  final Enemy enemy;

  const EnemyWidget({super.key, required this.enemy});

  Color getEnemyColor() {
    switch (enemy.type) {
      case 1: // Fast
        return Colors.red;
      case 2: // Strong
        return Colors.purple;
      default: // Normal
        return Colors.yellow;
    }
  }

  IconData getEnemyIcon() {
    switch (enemy.type) {
      case 1: // Fast
        return Icons.bug_report;
      case 2: // Strong
        return Icons.diamond;
      default: // Normal
        return Icons.space_dashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!enemy.alive) return SizedBox.shrink();
    
    // Try to load image asset, fallback to colored widget if not found
    return Image.asset(
      'assets/images/enemy.png',
      width: enemy.width,
      height: enemy.height,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to colored widget if image not found
        return Container(
      width: enemy.width,
      height: enemy.height,
      decoration: BoxDecoration(
        color: getEnemyColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: getEnemyColor().withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        getEnemyIcon(),
        color: Colors.white,
        size: enemy.width * 0.6,
      ),
    );
      },
    );
  }
}
