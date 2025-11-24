import 'dart:math' as math;

import 'package:flutter/material.dart';

class ShieldAura extends StatelessWidget {
  final double width;
  final double height;
  final double time;

  const ShieldAura({
    super.key,
    required this.width,
    required this.height,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = 1.1 + math.sin(time * 6) * 0.05;
    final double opacity = 0.35 + (math.cos(time * 8) * 0.15);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: width * 1.4,
        height: height * 1.4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.6 + opacity),
              Colors.lightBlueAccent.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4 + opacity),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}
