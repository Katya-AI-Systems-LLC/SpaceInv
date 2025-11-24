import 'package:flutter/material.dart';

import '../services/achievements_service.dart';
import '../services/localization_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementsService _achievementsService = AchievementsService();
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final items = await _achievementsService.getAchievements();
    setState(() {
      _achievements = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.t('title_achievements')),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAchievements,
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            final a = _achievements[index];
            final unlocked = a.unlocked;
            final color = unlocked ? Colors.green : Colors.grey;
            return Card(
              color: Colors.black54,
              child: ListTile(
                leading: Icon(
                  unlocked ? Icons.emoji_events : Icons.lock_outline,
                  color: color,
                  size: 32,
                ),
                title: Text(
                  a.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  a.description,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                trailing: Icon(
                  unlocked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
