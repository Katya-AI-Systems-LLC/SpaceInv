import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';
import '../models/upgrade_type.dart';
import 'statistics_service.dart';
import 'currency_service.dart';
import 'upgrades_service.dart';
import 'campaign_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

class AchievementsService {
  static final AchievementsService _instance = AchievementsService._internal();
  factory AchievementsService() => _instance;
  AchievementsService._internal();

  static const String _prefix = 'achievement_';

  Future<void> updateAchievementsOnGameEnd({
    required int score,
    required int level,
    required int enemiesKilled,
    required bool won,
    GameMode? mode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await StatisticsService().getStatistics();
      final currency = CurrencyService();
      final upgrades = UpgradesService();
      final campaign = CampaignService();

      Future<void> unlock(String id) async {
        final key = '$_prefix$id';
        final alreadyUnlocked = prefs.getBool(key) ?? false;
        if (!alreadyUnlocked) {
          await prefs.setBool(key, true);
        }
      }

      final gamesPlayed = stats['games_played'] ?? 0;
      final totalEnemiesKilled = stats['total_enemies_killed'] ?? 0;
      final highScore = stats['high_score'] ?? 0;
      final highestLevel = stats['highest_level'] ?? 0;
      final gamesWon = stats['games_won'] ?? 0;
      final totalCredits = await currency.getCredits();
      final currentMode = mode;
      final maxMissionIndex = await campaign.getMaxCompletedMissionIndex();
      final bool hasAnyUpgrade = UpgradeType.values
          .any((t) => upgrades.getLevel(t) > 0);

      if (gamesPlayed >= 1) {
        await unlock('first_game');
      }
      if (totalEnemiesKilled >= 1) {
        await unlock('first_blood');
      }
      if (gamesWon >= 1) {
        await unlock('first_win');
      }
      if (gamesPlayed >= 50) {
        await unlock('veteran');
      }
      if (highScore >= 3000) {
        await unlock('score_1000');
      }
      if (highestLevel >= 10) {
        await unlock('level_5');
      }

      // Boss Rush achievements
      if (currentMode == GameMode.bossRush && level >= 5) {
        await unlock('boss_rush_3');
      }
      if (currentMode == GameMode.bossRush && level >= 8) {
        await unlock('boss_rush_5');
      }
      if (currentMode == GameMode.bossRush && level >= 12) {
        await unlock('boss_rush_8');
      }

      // Galactic Run achievements
      if (currentMode == GameMode.galacticRun && level >= 8) {
        await unlock('galactic_run_5');
      }
      if (currentMode == GameMode.galacticRun && score >= 5000) {
        await unlock('galactic_run_score_3000');
      }

      // Meta progression / hangar
      if (totalCredits >= 1000) {
        await unlock('credits_500');
      }
      if (totalCredits >= 20000) {
        await unlock('credits_5000');
      }
      if (hasAnyUpgrade) {
        await unlock('first_upgrade');
      }

      // Campaign progress
      if (maxMissionIndex >= 0) {
        await unlock('campaign_first');
      }
      if (maxMissionIndex >= 4) {
        await unlock('campaign_all');
      }
    } catch (e) {
      // ignore if prefs not available
    }
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await StatisticsService().getStatistics();

      bool isUnlocked(String id) {
        return prefs.getBool('$_prefix$id') ?? false;
      }

      return [
        Achievement(
          id: 'first_game',
          title: 'First Game',
          description: 'Play your first game.',
          unlocked: isUnlocked('first_game'),
        ),
        Achievement(
          id: 'first_blood',
          title: 'First Blood',
          description: 'Destroy your first enemy.',
          unlocked: isUnlocked('first_blood'),
        ),
        Achievement(
          id: 'score_1000',
          title: 'Score Hunter',
          description:
              'Reach a high score of at least 3000 points. Current best: ${stats['high_score'] ?? 0}.',
          unlocked: isUnlocked('score_1000'),
        ),
        Achievement(
          id: 'level_5',
          title: 'Deep Space',
          description:
              'Reach level 10 or higher. Current max level: ${stats['highest_level'] ?? 0}.',
          unlocked: isUnlocked('level_5'),
        ),
        Achievement(
          id: 'first_win',
          title: 'First Victory',
          description: 'Win a game.',
          unlocked: isUnlocked('first_win'),
        ),
        Achievement(
          id: 'veteran',
          title: 'Veteran Pilot',
          description:
              'Play at least 50 games. Games played: ${stats['games_played'] ?? 0}.',
          unlocked: isUnlocked('veteran'),
        ),
        Achievement(
          id: 'boss_rush_3',
          title: 'Boss Rush Initiate',
          description: 'Reach level 5 in Boss Rush mode.',
          unlocked: isUnlocked('boss_rush_3'),
        ),
        Achievement(
          id: 'boss_rush_5',
          title: 'Boss Rush Veteran',
          description: 'Reach level 8 in Boss Rush mode.',
          unlocked: isUnlocked('boss_rush_5'),
        ),
        Achievement(
          id: 'boss_rush_8',
          title: 'Boss Rush Legend',
          description: 'Reach level 12 in Boss Rush mode.',
          unlocked: isUnlocked('boss_rush_8'),
        ),
        Achievement(
          id: 'galactic_run_5',
          title: 'Rogue Runner',
          description: 'Reach level 8 in Galactic Run mode.',
          unlocked: isUnlocked('galactic_run_5'),
        ),
        Achievement(
          id: 'galactic_run_score_3000',
          title: 'Chaos Tamer',
          description: 'Score at least 5000 points in a single Galactic Run.',
          unlocked: isUnlocked('galactic_run_score_3000'),
        ),
        Achievement(
          id: 'credits_500',
          title: 'Quartermaster',
          description: 'Accumulate at least 1000 credits.',
          unlocked: isUnlocked('credits_500'),
        ),
        Achievement(
          id: 'credits_5000',
          title: 'War Chest',
          description: 'Accumulate at least 20000 credits.',
          unlocked: isUnlocked('credits_5000'),
        ),
        Achievement(
          id: 'first_upgrade',
          title: 'Engineer',
          description: 'Purchase your first hangar upgrade.',
          unlocked: isUnlocked('first_upgrade'),
        ),
        Achievement(
          id: 'campaign_first',
          title: 'Story Begins',
          description: 'Complete the first campaign mission.',
          unlocked: isUnlocked('campaign_first'),
        ),
        Achievement(
          id: 'campaign_all',
          title: 'Campaign Hero',
          description: 'Complete all campaign missions.',
          unlocked: isUnlocked('campaign_all'),
        ),
      ];
    } catch (e) {
      return [];
    }
  }
}
