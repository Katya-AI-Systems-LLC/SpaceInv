import 'package:shared_preferences/shared_preferences.dart';

import '../models/upgrade_type.dart';
import 'currency_service.dart';

class UpgradesService {
  static final UpgradesService _instance = UpgradesService._internal();
  factory UpgradesService() => _instance;
  UpgradesService._internal();

  static const String _keyPrefix = 'upgrade_level_';

  final Map<UpgradeType, int> _levels = {
    UpgradeType.extraLife: 0,
    UpgradeType.shieldStrength: 0,
    UpgradeType.dropChance: 0,
    UpgradeType.startingPower: 0,
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final type in UpgradeType.values) {
      final key = '$_keyPrefix${type.name}';
      _levels[type] = prefs.getInt(key) ?? 0;
    }
  }

  int getLevel(UpgradeType type) => _levels[type] ?? 0;

  int getMaxLevel(UpgradeType type) {
    switch (type) {
      case UpgradeType.extraLife:
        return 3;
      case UpgradeType.shieldStrength:
        return 3;
      case UpgradeType.dropChance:
        return 3;
      case UpgradeType.startingPower:
        return 2;
    }
  }

  int getNextLevelPrice(UpgradeType type) {
    final level = getLevel(type);
    final base = 100;
    return base * (level + 1);
  }

  Future<bool> upgrade(UpgradeType type) async {
    final currentLevel = getLevel(type);
    final maxLevel = getMaxLevel(type);
    if (currentLevel >= maxLevel) {
      return false;
    }
    final price = getNextLevelPrice(type);
    final currency = CurrencyService();
    final ok = await currency.spendIfPossible(price);
    if (!ok) {
      return false;
    }
    final newLevel = currentLevel + 1;
    _levels[type] = newLevel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefix${type.name}', newLevel);
    return true;
  }
}
