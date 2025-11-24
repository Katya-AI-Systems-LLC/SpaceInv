import 'package:flutter/material.dart';
import '../models/power_up.dart';

class PowerUpWidget extends StatelessWidget {
  final PowerUp powerUp;

  const PowerUpWidget({super.key, required this.powerUp});

  @override
  Widget build(BuildContext context) {
    final baseColor = powerUp.getColor();
    return Container(
      width: powerUp.width + 8,
      height: powerUp.height + 8,
      alignment: Alignment.center,
      child: Container(
        width: powerUp.width,
        height: powerUp.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.9),
              baseColor.withValues(alpha: 0.9),
              baseColor.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.7),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
        ),
        child: Icon(
          powerUp.getIcon(),
          color: Colors.white,
          size: powerUp.width * 0.6,
        ),
      ),
    );
  }
}
