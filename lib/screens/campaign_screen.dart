import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../services/campaign_service.dart';
import '../services/localization_service.dart';
import 'game_screen.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final CampaignService _campaignService = CampaignService();
  int _maxCompletedIndex = -1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final value = await _campaignService.getMaxCompletedMissionIndex();
    if (!mounted) return;
    setState(() {
      _maxCompletedIndex = value;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.t('title_campaign')),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgress,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.indigo.shade900],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _campaignService.missions.length,
                itemBuilder: (context, index) {
                  final mission = _campaignService.missions[index];
                  final isCompleted = index <= _maxCompletedIndex;
                  final isUnlocked = index == _maxCompletedIndex + 1 || isCompleted;
                  final isLocked = !isUnlocked;
                  return Opacity(
                    opacity: isLocked ? 0.5 : 1.0,
                    child: Card(
                      color: Colors.black54,
                      child: ListTile(
                        onTap: isLocked ? null : () => _startMission(index),
                        leading: Icon(
                          _iconForMode(mission.mode),
                          color: isCompleted ? Colors.amber : Colors.greenAccent,
                        ),
                        title: Text(
                          loc.t(mission.titleKey),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              loc.t(mission.descriptionKey),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  mission.mode.label,
                                  style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _statusLabel(loc, isCompleted, isLocked),
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.amber
                                        : (isLocked
                                            ? Colors.redAccent
                                            : Colors.greenAccent),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.amber)
                            : isLocked
                                ? const Icon(Icons.lock, color: Colors.redAccent)
                                : const Icon(Icons.play_arrow,
                                    color: Colors.greenAccent),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _statusLabel(LocalizationService loc, bool completed, bool locked) {
    if (completed) return loc.t('campaign_completed');
    if (locked) return loc.t('campaign_locked');
    return loc.t('campaign_available');
  }

  void _startMission(int index) {
    final mission = _campaignService.missions[index];
    final loc = LocalizationService();
    final introText = loc.t(mission.introKey ?? mission.descriptionKey);

    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            loc.t(mission.titleKey),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            introText,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Launch',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed != true) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            mode: mission.mode,
            campaignMissionId: mission.id,
          ),
        ),
      );
    });
  }

  IconData _iconForMode(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return Icons.auto_awesome;
      case GameMode.survival:
        return Icons.all_inclusive;
      case GameMode.hardcore:
        return Icons.warning;
      case GameMode.galacticRun:
        return Icons.rocket_launch;
      case GameMode.bossRush:
        return Icons.psychology;
    }
  }
}
