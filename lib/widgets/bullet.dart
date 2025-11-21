import 'package:flutter/material.dart';
import '../game_state.dart';

class BulletWidget extends StatelessWidget {
  final Bullet bullet;

  const BulletWidget({super.key, required this.bullet});

  @override
  Widget build(BuildContext context) {
    // Try to load image asset, fallback to colored widget if not found
    return Image.asset(
      'assets/images/bullet.png',
      width: bullet.width,
      height: bullet.height,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to colored widget if image not found
        return Container(
      width: bullet.width,
      height: bullet.height,
      decoration: BoxDecoration(
        color: bullet.isPlayerBullet ? Colors.cyanAccent : Colors.redAccent,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: bullet.isPlayerBullet ? Colors.cyanAccent : Colors.redAccent,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
      },
    );
  }
}
