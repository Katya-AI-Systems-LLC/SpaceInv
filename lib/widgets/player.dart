import 'package:flutter/material.dart';
import '../game_state.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;

  const PlayerWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    // Try to load image asset, fallback to colored widget if not found
    return Image.asset(
      'assets/images/player.png',
      width: player.width,
      height: player.height,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to colored widget if image not found
        return Container(
      width: player.width,
      height: player.height,
      decoration: BoxDecoration(
        color: player.isInvulnerable ? Colors.blueAccent : Colors.green,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: player.isInvulnerable ? Colors.blueAccent : Colors.green,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.rocket_launch,
        color: Colors.white,
        size: player.width * 0.7,
      ),
    );
      },
    );
  }
}
