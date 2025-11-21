import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  Future<void> recordGame({
    required int score,
    required int level,
    required int enemiesKilled,
    required bool won,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Total games played
      final gamesPlayed = prefs.getInt('games_played') ?? 0;
      await prefs.setInt('games_played', gamesPlayed + 1);
      
      // Total score
      final totalScore = prefs.getInt('total_score') ?? 0;
      await prefs.setInt('total_score', totalScore + score);
      
      // Highest level reached
      final highestLevel = prefs.getInt('highest_level') ?? 0;
      if (level > highestLevel) {
        await prefs.setInt('highest_level', level);
      }
      
      // Total enemies killed
      final totalEnemiesKilled = prefs.getInt('total_enemies_killed') ?? 0;
      await prefs.setInt('total_enemies_killed', totalEnemiesKilled + enemiesKilled);
      
      // Games won
      if (won) {
        final gamesWon = prefs.getInt('games_won') ?? 0;
        await prefs.setInt('games_won', gamesWon + 1);
      }
      
      // Best score (already handled in game_over_screen, but keeping for consistency)
      final bestScore = prefs.getInt('high_score') ?? 0;
      if (score > bestScore) {
        await prefs.setInt('high_score', score);
      }
    } catch (e) {
      // Ignore if prefs not available
    }
  }

  Future<Map<String, int>> getStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'games_played': prefs.getInt('games_played') ?? 0,
        'total_score': prefs.getInt('total_score') ?? 0,
        'high_score': prefs.getInt('high_score') ?? 0,
        'highest_level': prefs.getInt('highest_level') ?? 0,
        'total_enemies_killed': prefs.getInt('total_enemies_killed') ?? 0,
        'games_won': prefs.getInt('games_won') ?? 0,
      };
    } catch (e) {
      return {
        'games_played': 0,
        'total_score': 0,
        'high_score': 0,
        'highest_level': 0,
        'total_enemies_killed': 0,
        'games_won': 0,
      };
    }
  }

  Future<void> resetStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('games_played', 0);
      await prefs.setInt('total_score', 0);
      await prefs.setInt('highest_level', 0);
      await prefs.setInt('total_enemies_killed', 0);
      await prefs.setInt('games_won', 0);
      // Don't reset high_score
    } catch (e) {
      // Ignore if prefs not available
    }
  }
}

