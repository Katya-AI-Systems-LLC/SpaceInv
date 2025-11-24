import 'game_mode.dart';

class CampaignMission {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final GameMode mode;
  final int requiredLevel;
  final int? requiredScore;
  final int? requiredKills;
  final bool requireWin;
  final String? introKey;

  const CampaignMission({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.mode,
    required this.requiredLevel,
    this.requiredScore,
    this.requiredKills,
    this.requireWin = false,
    this.introKey,
  });

  bool isCompletedBy({
    required int level,
    required int score,
    required int enemiesKilled,
    required GameMode playedMode,
    required bool won,
  }) {
    if (playedMode != mode) {
      return false;
    }
    if (requireWin && !won) {
      return false;
    }
    if (level < requiredLevel) {
      return false;
    }
    if (requiredScore != null && score < requiredScore!) {
      return false;
    }
    if (requiredKills != null && enemiesKilled < requiredKills!) {
      return false;
    }
    return true;
  }
}
