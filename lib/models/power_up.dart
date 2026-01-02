import 'package:flutter/material.dart';
import 'dart:math' as math;

enum PowerUpType {
  multiShot,
  shield,
  speedBoost,
  lifeUp,
  weaponUpgrade,
  energyBoost,
  timeBomb,
  magnet,
  drone,
  freeze,
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
    final random = math.Random();
    
    // Weighted random selection
    final weights = [
      20, // multiShot
      15, // shield
      15, // speedBoost
      10, // lifeUp
      15, // weaponUpgrade
      10, // energyBoost
      5,  // timeBomb
      5,  // magnet
      3,  // drone
      2,  // freeze
    ];
    
    final totalWeight = weights.reduce((a, b) => a + b);
    var randomWeight = random.nextInt(totalWeight);
    
    for (int i = 0; i < types.length; i++) {
      randomWeight -= weights[i];
      if (randomWeight <= 0) {
        return types[i];
      }
    }
    
    return PowerUpType.multiShot;
  }

  String getTypeName() {
    return name;
  }

  IconData getIcon() {
    switch (type) {
      case PowerUpType.multiShot:
        return Icons.flash_on;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.speedBoost:
        return Icons.speed;
      case PowerUpType.lifeUp:
        return Icons.favorite;
      case PowerUpType.weaponUpgrade:
        return Icons.upgrade;
      case PowerUpType.energyBoost:
        return Icons.bolt;
      case PowerUpType.timeBomb:
        return Icons.timer;
      case PowerUpType.magnet:
        return Icons.radio_button_unchecked;
      case PowerUpType.drone:
        return Icons.airplanemode_active;
      case PowerUpType.freeze:
        return Icons.ac_unit;
    }
  }
  
  Color get color {
    switch (type) {
      case PowerUpType.multiShot:
        return Colors.amber;
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.speedBoost:
        return Colors.green;
      case PowerUpType.lifeUp:
        return Colors.red;
      case PowerUpType.weaponUpgrade:
        return Colors.purple;
      case PowerUpType.energyBoost:
        return Colors.cyan;
      case PowerUpType.timeBomb:
        return Colors.orange;
      case PowerUpType.magnet:
        return Colors.pink;
      case PowerUpType.drone:
        return Colors.teal;
      case PowerUpType.freeze:
        return Colors.lightBlue;
    }
  }
  
  String get name {
    switch (type) {
      case PowerUpType.multiShot:
        return 'Multi-Shot';
      case PowerUpType.shield:
        return 'Shield';
      case PowerUpType.speedBoost:
        return 'Speed Boost';
      case PowerUpType.lifeUp:
        return 'Extra Life';
      case PowerUpType.weaponUpgrade:
        return 'Weapon Upgrade';
      case PowerUpType.energyBoost:
        return 'Energy Boost';
      case PowerUpType.timeBomb:
        return 'Time Bomb';
      case PowerUpType.magnet:
        return 'Magnet';
      case PowerUpType.drone:
        return 'Drone';
      case PowerUpType.freeze:
        return 'Freeze';
    }
  }
  
  String get description {
    switch (type) {
      case PowerUpType.multiShot:
        return 'Fire multiple bullets';
      case PowerUpType.shield:
        return 'Temporary invulnerability';
      case PowerUpType.speedBoost:
        return 'Move faster';
      case PowerUpType.lifeUp:
        return 'Gain an extra life';
      case PowerUpType.weaponUpgrade:
        return 'Upgrade current weapon';
      case PowerUpType.energyBoost:
        return 'Restore weapon energy';
      case PowerUpType.timeBomb:
        return 'Clear screen after delay';
      case PowerUpType.magnet:
        return 'Attract power-ups';
      case PowerUpType.drone:
        return 'Auto-firing drone';
      case PowerUpType.freeze:
        return 'Freeze enemies';
    }
  }
}
