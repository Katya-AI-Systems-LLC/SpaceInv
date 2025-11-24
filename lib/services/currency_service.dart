import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  static const String _creditsKey = 'meta_credits_v1';

  Future<int> getCredits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_creditsKey) ?? 0;
  }

  Future<void> setCredits(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditsKey, value.clamp(0, 1000000000));
  }

  Future<int> addCredits(int delta) async {
    final current = await getCredits();
    final updated = current + delta;
    await setCredits(updated);
    return updated;
  }

  Future<bool> spendIfPossible(int amount) async {
    if (amount <= 0) return true;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_creditsKey) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_creditsKey, current - amount);
    return true;
  }

  Future<int> addCreditsForGame({
    required int score,
    required int level,
    required int enemiesKilled,
    required bool won,
  }) async {
    int base = score ~/ 10;
    base += enemiesKilled ~/ 2;
    base += level * 5;
    if (won) {
      base += 50;
    }
    if (base <= 0) {
      return 0;
    }
    await addCredits(base);
    return base;
  }
}
