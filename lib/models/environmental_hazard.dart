import 'dart:math' as math;
import 'package:flutter/material.dart';

enum HazardType {
  asteroid,
  spaceDebris,
  blackHole,
  solarFlare,
  comet,
  nebula,
}

class EnvironmentalHazard {
  final HazardType type;
  double x;
  double y;
  double width;
  double height;
  double speed;
  double rotation;
  double rotationSpeed;
  bool active;
  int health;
  double effectRadius;
  
  EnvironmentalHazard({
    required this.type,
    required this.x,
    required this.y,
    this.width = 60,
    this.height = 60,
    this.speed = 1.0,
    this.rotation = 0,
    this.rotationSpeed = 0.05,
    this.active = true,
    this.health = 1,
    this.effectRadius = 100,
  });

  void update(double deltaTime) {
    // Update position based on type
    switch (type) {
      case HazardType.asteroid:
      case HazardType.spaceDebris:
        y += speed;
        x += math.sin(rotation) * 0.5;
        break;
      case HazardType.comet:
        y += speed * 1.5;
        x += math.cos(rotation) * 0.3;
        break;
      case HazardType.blackHole:
        rotation += rotationSpeed;
        break;
      case HazardType.solarFlare:
        rotation += rotationSpeed * 2;
        break;
      case HazardType.nebula:
        x += math.sin(rotation) * 0.2;
        break;
    }
    
    rotation += rotationSpeed;
  }

  bool get isDestructible => type == HazardType.asteroid || type == HazardType.spaceDebris;
  bool get affectsPlayer => type == HazardType.blackHole || type == HazardType.solarFlare;
  bool get affectsProjectiles => type == HazardType.nebula || type == HazardType.blackHole;

  Color get color {
    switch (type) {
      case HazardType.asteroid:
        return Colors.brown[300]!;
      case HazardType.spaceDebris:
        return Colors.grey[400]!;
      case HazardType.blackHole:
        return Colors.purple[900]!;
      case HazardType.solarFlare:
        return Colors.orange[400]!;
      case HazardType.comet:
        return Colors.lightBlue[300]!;
      case HazardType.nebula:
        return Colors.purple[200]!.withOpacity(0.6);
    }
  }

  String get name {
    switch (type) {
      case HazardType.asteroid:
        return 'Asteroid';
      case HazardType.spaceDebris:
        return 'Space Debris';
      case HazardType.blackHole:
        return 'Black Hole';
      case HazardType.solarFlare:
        return 'Solar Flare';
      case HazardType.comet:
        return 'Comet';
      case HazardType.nebula:
        return 'Nebula';
    }
  }
}

class HazardManager {
  final List<EnvironmentalHazard> hazards = [];
  final math.Random _random = math.Random();
  double _lastSpawnTime = 0;
  
  void update(double deltaTime, double screenWidth, double screenHeight, int level) {
    // Update existing hazards
    for (var hazard in hazards) {
      hazard.update(deltaTime);
    }
    
    // Remove off-screen hazards
    hazards.removeWhere((hazard) => hazard.y > screenHeight + 100);
    
    // Spawn new hazards
    _lastSpawnTime += deltaTime;
    double spawnInterval = math.max(3.0 - level * 0.2, 1.0);
    
    if (_lastSpawnTime > spawnInterval) {
      _spawnHazard(screenWidth);
      _lastSpawnTime = 0;
    }
  }
  
  void _spawnHazard(double screenWidth) {
    final type = HazardType.values[_random.nextInt(HazardType.values.length)];
    final x = _random.nextDouble() * (screenWidth - 60);
    
    switch (type) {
      case HazardType.asteroid:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: -60,
          width: 40 + _random.nextDouble() * 40,
          height: 40 + _random.nextDouble() * 40,
          speed: 1.0 + _random.nextDouble() * 2,
          rotationSpeed: 0.02 + _random.nextDouble() * 0.08,
          health: 2 + _random.nextInt(3),
        ));
        break;
      case HazardType.spaceDebris:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: -40,
          width: 20 + _random.nextDouble() * 30,
          height: 20 + _random.nextDouble() * 30,
          speed: 2.0 + _random.nextDouble() * 3,
          rotationSpeed: 0.05 + _random.nextDouble() * 0.15,
          health: 1,
        ));
        break;
      case HazardType.blackHole:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: 100 + _random.nextDouble() * 200,
          width: 80,
          height: 80,
          speed: 0,
          rotationSpeed: 0.03,
          effectRadius: 150,
        ));
        break;
      case HazardType.solarFlare:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: 50 + _random.nextDouble() * 150,
          width: 100,
          height: 60,
          speed: 0.5,
          rotationSpeed: 0.08,
          effectRadius: 120,
        ));
        break;
      case HazardType.comet:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: -80,
          width: 30,
          height: 50,
          speed: 3.0 + _random.nextDouble() * 2,
          rotationSpeed: 0.1,
          effectRadius: 80,
        ));
        break;
      case HazardType.nebula:
        hazards.add(EnvironmentalHazard(
          type: type,
          x: x,
          y: 100 + _random.nextDouble() * 200,
          width: 120,
          height: 80,
          speed: 0.3,
          rotationSpeed: 0.01,
          effectRadius: 100,
        ));
        break;
    }
  }
  
  void clear() {
    hazards.clear();
  }
}
