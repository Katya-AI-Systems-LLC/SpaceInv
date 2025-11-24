import 'package:shared_preferences/shared_preferences.dart';

import '../models/campaign_mission.dart';
import '../models/game_mode.dart';

class CampaignService {
  static final CampaignService _instance = CampaignService._internal();
  factory CampaignService() => _instance;
  CampaignService._internal();

  static const String _progressKey = 'campaign_max_completed_index_v1';

  final List<CampaignMission> missions = [
    CampaignMission(
      id: 'mission_1',
      titleKey: 'campaign_m1_title',
      descriptionKey: 'campaign_m1_desc',
      introKey: 'campaign_m1_intro',
      mode: GameMode.classic,
      requiredLevel: 2,
      requiredScore: 200,
      requiredKills: 20,
    ),
    CampaignMission(
      id: 'mission_2',
      titleKey: 'campaign_m2_title',
      descriptionKey: 'campaign_m2_desc',
      introKey: 'campaign_m2_intro',
      mode: GameMode.classic,
      requiredLevel: 4,
      requiredScore: 600,
      requiredKills: 60,
    ),
    CampaignMission(
      id: 'mission_3',
      titleKey: 'campaign_m3_title',
      descriptionKey: 'campaign_m3_desc',
      introKey: 'campaign_m3_intro',
      mode: GameMode.survival,
      requiredLevel: 5,
      requiredScore: 1000,
      requiredKills: 80,
    ),
    CampaignMission(
      id: 'mission_4',
      titleKey: 'campaign_m4_title',
      descriptionKey: 'campaign_m4_desc',
      introKey: 'campaign_m4_intro',
      mode: GameMode.hardcore,
      requiredLevel: 3,
      requiredScore: 800,
      requiredKills: 50,
    ),
    CampaignMission(
      id: 'mission_5',
      titleKey: 'campaign_m5_title',
      descriptionKey: 'campaign_m5_desc',
      introKey: 'campaign_m5_intro',
      mode: GameMode.galacticRun,
      requiredLevel: 4,
      requiredScore: 1200,
      requiredKills: 80,
    ),
  ];

  Future<int> getMaxCompletedMissionIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_progressKey) ?? -1;
  }

  Future<void> _saveMaxCompletedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey, index);
  }

  CampaignMission? getMissionById(String id) {
    try {
      return missions.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> onGameFinished({
    required String missionId,
    required int level,
    required int score,
    required int enemiesKilled,
    required GameMode mode,
    required bool won,
  }) async {
    final index = missions.indexWhere((m) => m.id == missionId);
    if (index == -1) {
      return false;
    }
    final mission = missions[index];
    final completed = mission.isCompletedBy(
      level: level,
      score: score,
      enemiesKilled: enemiesKilled,
      playedMode: mode,
      won: won,
    );
    if (!completed) {
      return false;
    }

    final currentMax = await getMaxCompletedMissionIndex();
    if (index > currentMax) {
      await _saveMaxCompletedIndex(index);
    }
    return true;
  }
}
