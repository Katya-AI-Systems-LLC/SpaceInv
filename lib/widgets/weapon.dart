import 'package:flutter/material.dart';
import '../models/weapon.dart';

class WeaponWidget extends StatelessWidget {
  final Weapon weapon;
  final bool isActive;
  final double energy;
  
  const WeaponWidget({
    super.key,
    required this.weapon,
    this.isActive = false,
    this.energy = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? weapon.color.withOpacity(0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? weapon.color : Colors.white54,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getWeaponIcon(),
            color: isActive ? weapon.color : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            weapon.name,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Energy bar
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: energy / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: energy > 30 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getWeaponIcon() {
    switch (weapon.type) {
      case WeaponType.basic:
        return Icons.radio_button_checked;
      case WeaponType.spread:
        return Icons.grain;
      case WeaponType.laser:
        return Icons.linear_scale;
      case WeaponType.plasma:
        return Icons.brightness_7;
      case WeaponType.rocket:
        return Icons.rocket;
      case WeaponType.wave:
        return Icons.waves;
    }
  }
}

class SpecialAbilityWidget extends StatelessWidget {
  final SpecialAbilityState ability;
  
  const SpecialAbilityWidget({
    super.key,
    required this.ability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ability.isActive 
            ? ability.color.withOpacity(0.3)
            : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ability.canUse ? ability.color : Colors.white38,
          width: ability.isActive ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                ability.icon,
                color: ability.canUse 
                    ? (ability.isActive ? ability.color : Colors.white)
                    : Colors.white38,
                size: 24,
              ),
              if (!ability.canUse && !ability.isActive)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: ability.cooldownProgress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ability.color.withOpacity(0.7),
                    ),
                    backgroundColor: Colors.white24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ability.name,
            style: TextStyle(
              color: ability.canUse 
                  ? (ability.isActive ? Colors.white : Colors.white70)
                  : Colors.white38,
              fontSize: 9,
              fontWeight: ability.isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (ability.isActive) ...[
            const SizedBox(height: 2),
            Container(
              width: 35,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ability.durationProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: ability.color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BulletTrailWidget extends StatelessWidget {
  final double x;
  final double y;
  final WeaponType weaponType;
  final bool isPlayerBullet;
  
  const BulletTrailWidget({
    super.key,
    required this.x,
    required this.y,
    required this.weaponType,
    this.isPlayerBullet = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    double width;
    double height;
    
    switch (weaponType) {
      case WeaponType.basic:
        color = Colors.yellow;
        width = 5;
        height = 15;
        break;
      case WeaponType.spread:
        color = Colors.orange;
        width = 4;
        height = 12;
        break;
      case WeaponType.laser:
        color = Colors.red;
        width = 3;
        height = 25;
        break;
      case WeaponType.plasma:
        color = Colors.purple;
        width = 6;
        height = 18;
        break;
      case WeaponType.rocket:
        color = Colors.green;
        width = 8;
        height = 20;
        break;
      case WeaponType.wave:
        color = Colors.cyan;
        width = 4;
        height = 15;
        break;
    }
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
