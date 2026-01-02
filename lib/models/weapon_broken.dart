import 'package:flutter/material.dart';
import 'dart:math' as math;

enum WeaponType {
  basic,
  spread,
  laser,
  plasma,
  rocket,
  wave,
}

enum SpecialAbility {
  timeSlow,
  screenClear,
  megaShield,
  rapidFire,
}

class Weapon {
  final WeaponType type;
  final int level;
  final double damage;
  final double fireRate;
  final int projectileCount;
  final double spread;
  
  Weapon({
    required this.type,
    this.level = 1,
    this.damage = 1.0,
    this.fireRate = 1.0,
    this.projectileCount = 1,
    this.spread = 0.0,
  });

  Weapon copyWith({
    WeaponType? type,
    int? level,
    double? damage,
    double? fireRate,
    int? projectileCount,
    double? spread,
  }) {
    return Weapon(
      type: type ?? this.type,
      level: level ?? this.level,
      damage: damage ?? this.damage,
      fireRate: fireRate ?? this.fireRate,
      projectileCount: projectileCount ?? this.projectileCount,
      spread: spread ?? this.spread,
    );
  }

  factory Weapon.basic() => Weapon(type: WeaponType.basic, damage: 1.0, fireRate: 1.0);
  factory Weapon.spread() => Weapon(type: WeaponType.spread, damage: 0.8, fireRate: 0.8, projectileCount: 3, spread: 30);
  factory Weapon.laser() => Weapon(type: WeaponType.laser, damage: 2.0, fireRate: 0.6, projectileCount: 1);
  factory Weapon.plasma() => Weapon(type: WeaponType.plasma, damage: 1.5, fireRate: 1.2, projectileCount: 2, spread: 10);
  factory Weapon.rocket() => Weapon(type: WeaponType.rocket, damage: 3.0, fireRate: 0.4, projectileCount: 1);
  factory Weapon.wave() => Weapon(type: WeaponType.wave, damage: 1.2, fireRate: 0.9, projectileCount: 1);

  String get name {
    switch (type) {
      case WeaponType.basic:
        return 'Basic Cannon';
      case WeaponType.spread:
        return 'Spread Shot';
      case WeaponType.laser:
        return 'Laser Beam';
      case WeaponType.plasma:
        return 'Plasma Cannon';
      case WeaponType.rocket:
        return 'Rocket Launcher';
      case WeaponType.wave:
        return 'Wave Gun';
    }
  }

  Color get color {
    switch (type) {
      case WeaponType.basic:
        return Colors.yellow;
      case WeaponType.spread:
        return Colors.orange;
      case WeaponType.laser:
        return Colors.red;
      case WeaponType.plasma:
        return Colors.purple;
      case WeaponType.rocket:
        return Colors.green;
      case WeaponType.wave:
        return Colors.cyan;
    }
  }
}

class SpecialAbilityState {
  final SpecialAbility type;
  double cooldown;
  double maxCooldown;
  bool isActive;
  double duration;
  double maxDuration;
  
  SpecialAbilityState({
    required this.type,
    this.cooldown = 0,
    this.maxCooldown = 30,
    this.isActive = false,
    this.duration = 0,
    this.maxDuration = 5,
  });

  void update(double deltaTime) {
    if (isActive) {
      duration -= deltaTime;
      if (duration <= 0) {
        isActive = false;
        duration = 0;
      }
    } else if (cooldown > 0) {
      cooldown -= deltaTime;
      if (cooldown < 0) cooldown = 0;
    }
  }

  bool get canUse => cooldown <= 0 && !isActive;
  double get cooldownProgress => 1.0 - (cooldown / maxCooldown);
  double get durationProgress => duration / maxDuration;

  void activate() {
    if (canUse) {
      isActive = true;
      duration = maxDuration;
      cooldown = maxCooldown;
    }
  }

  String get name {
    switch (type) {
      case SpecialAbility.timeSlow:
        return 'Time Slow';
      case SpecialAbility.screenClear:
        return 'Screen Clear';
      case SpecialAbility.megaShield:
        return 'Mega Shield';
      case SpecialAbility.rapidFire:
        return 'Rapid Fire';
    }
  }

  IconData get icon {
    switch (type) {
      case SpecialAbility.timeSlow:
        return Icons.hourglass_bottom;
      case SpecialAbility.screenClear:
        return Icons.flash_on;
      case SpecialAbility.megaShield:
        return Icons.security;
      case SpecialAbility.rapidFire:
        return Icons.bolt;
    }
  }

  Color get color {
    switch (type) {
      case SpecialAbility.timeSlow:
        return Colors.blue;
      case SpecialAbility.screenClear:
        return Colors.yellow;
      case SpecialAbility.megaShield:
        return Colors.green;
      case SpecialAbility.rapidFire:
        return Colors.red;
    }
  }
}
