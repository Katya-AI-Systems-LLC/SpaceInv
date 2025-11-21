import 'package:flutter/material.dart';
import 'dart:math' as math;

enum PowerUpType {
  multiShot,
  shield,
  speedBoost,
  lifeUp,
}

class PowerUp {
  double x;
  double y;
  double width = 30;
  double height = 30;
  double speed = 2;
  PowerUpType type;
  bool active = true;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
  });

  void move() {
    y += speed;
  }

  static PowerUpType getRandomType() {
    final types = PowerUpType.values;
    return types[math.Random().nextInt(types.length)];
  }

  String getTypeName() {
    switch (type) {
      case PowerUpType.multiShot:
        return 'Multi Shot';
      case PowerUpType.shield:
        return 'Shield';
      case PowerUpType.speedBoost:
        return 'Speed Boost';
      case PowerUpType.lifeUp:
        return 'Life Up';
    }
  }

  IconData getIcon() {
    switch (type) {
      case PowerUpType.multiShot:
        return Icons.auto_awesome;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.speedBoost:
        return Icons.speed;
      case PowerUpType.lifeUp:
        return Icons.favorite;
    }
  }

  Color getColor() {
    switch (type) {
      case PowerUpType.multiShot:
        return Colors.cyan;
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.speedBoost:
        return Colors.green;
      case PowerUpType.lifeUp:
        return Colors.red;
    }
  }
}

