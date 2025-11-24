import 'package:flutter/material.dart';

import '../models/barrier.dart';

class BarrierWidget extends StatelessWidget {
  final Barrier barrier;

  const BarrierWidget({super.key, required this.barrier});

  @override
  Widget build(BuildContext context) {
    final double ratio = (barrier.health / 4).clamp(0.0, 1.0);
    final Color baseColor = Color.lerp(Colors.redAccent, Colors.greenAccent, ratio) ?? Colors.greenAccent;

    return Container(
      width: barrier.width,
      height: barrier.height,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
