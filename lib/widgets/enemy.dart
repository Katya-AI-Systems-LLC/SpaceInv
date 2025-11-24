import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../game_state.dart';

class EnemyWidget extends StatelessWidget {
  final Enemy enemy;
  final double time;

  const EnemyWidget({super.key, required this.enemy, this.time = 0});

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
        final color = getEnemyColor();
        final pulse = 1 + math.sin(time * 6 + enemy.x * 0.05) * 0.08;
        final auraOpacity = enemy.isBoss ? 0.35 : 0.2;

        return SizedBox(
          width: enemy.width,
          height: enemy.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Aura / glow
              Transform.scale(
                scale: pulse * (enemy.isBoss ? 1.4 : 1.2),
                child: Container(
                  width: enemy.width,
                  height: enemy.height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.6),
                        color.withOpacity(auraOpacity),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Container(
                width: enemy.width,
                height: enemy.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withOpacity(0.5)],
                  ),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  getEnemyIcon(),
                  color: Colors.white,
                  size: enemy.width * (enemy.isBoss ? 0.5 : 0.6),
                ),
              ),
              if (enemy.isBoss)
                Positioned(
                  top: -enemy.height * 0.3,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amberAccent,
                    size: enemy.width * 0.4,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
