import 'package:flutter/material.dart';
import '../game_state.dart';
import 'shield_aura.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final double time;

  const PlayerWidget({super.key, required this.player, this.time = 0});

  @override
  Widget build(BuildContext context) {
    final bool shielded = player.isInvulnerable;

    final Widget sprite = Image.asset(
      'assets/images/player.png',
      width: player.width,
      height: player.height,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(shielded);
      },
    );

    if (!shielded) {
      return sprite;
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        ShieldAura(
          width: player.width,
          height: player.height,
          time: time,
        ),
        sprite,
      ],
    );
  }

  Widget _buildFallback(bool shielded) {
    final Color baseColor = shielded ? Colors.blueAccent : Colors.greenAccent;

    return SizedBox(
      width: player.width,
      height: player.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thruster flare
          Positioned(
            bottom: -player.height * 0.35,
            left: player.width * 0.3,
            right: player.width * 0.3,
            child: Container(
              height: player.height * 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orangeAccent.withOpacity(0.8),
                    Colors.redAccent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(player.width),
              ),
            ),
          ),
          // Ship body
          Container(
            width: player.width,
            height: player.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [baseColor, baseColor.withOpacity(0.3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: player.width * 0.65,
            ),
          ),
        ],
      ),
    );
  }
}
