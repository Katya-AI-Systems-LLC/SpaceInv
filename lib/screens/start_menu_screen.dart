 import 'package:flutter/material.dart';
 import '../models/game_mode.dart';
 import '../services/localization_service.dart';
 import 'game_screen.dart';
 import 'campaign_screen.dart';
 import 'hangar_screen.dart';
 import 'settings_screen.dart';
 import 'statistics_screen.dart';
 import 'achievements_screen.dart';
 import 'leaderboard_screen.dart';
 import '../utils/responsive_helper.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final responsive = ResponsiveHelper();
    responsive.initialize(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.indigo.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Title
              Text(
                loc.t('title_space_invaders'),
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: responsive.titleFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.greenAccent,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              responsive.scaledSizedBox(height: 60),
              
              // Start button
              ElevatedButton(
                onPressed: () async {
                  final selectedMode = await showDialog<GameMode>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        backgroundColor: Colors.black87,
                        title: const Text(
                          'Select Game Mode',
                          style: TextStyle(color: Colors.white),
                        ),
                        children: [
                          _buildModeOption(context, GameMode.classic),
                          _buildModeOption(context, GameMode.survival),
                          _buildModeOption(context, GameMode.hardcore),
                          _buildModeOption(context, GameMode.galacticRun),
                          _buildModeOption(context, GameMode.bossRush),
                        ],
                      );
                    },
                  );

                  if (selectedMode != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(mode: selectedMode),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_start_game'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),

              // Hangar button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HangarScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_hangar'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),
              
              // Campaign button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CampaignScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_campaign'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),
              
              // Statistics button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_statistics'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),
              
              // Leaderboard button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_leaderboard'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),
              
              // Achievements button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_achievements'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 15),
              
              // Settings button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  padding: responsive.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  loc.t('btn_settings'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              responsive.scaledSizedBox(height: 30),
              
              // Instructions
              Container(
                padding: responsive.screenPadding,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.t('menu_controls'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.uiFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    responsive.scaledSizedBox(height: 15),
                    _buildInstruction('← →', loc.t('ctrl_move'), responsive),
                    _buildInstruction('SPACE / TAP', loc.t('ctrl_shoot'), responsive),
                    _buildInstruction('P / ESC', loc.t('ctrl_pause'), responsive),
                  ],
                ),
              ),
              responsive.scaledSizedBox(height: 30),
              
              // Credits
              Text(
                loc.t('menu_tagline'),
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: responsive.buttonFontSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(BuildContext context, GameMode mode) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(_iconForMode(mode), color: Colors.greenAccent),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  mode.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _iconForMode(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return Icons.auto_awesome;
      case GameMode.survival:
        return Icons.all_inclusive;
      case GameMode.hardcore:
        return Icons.whatshot;
      case GameMode.galacticRun:
        return Icons.bolt;
      case GameMode.bossRush:
        return Icons.auto_fix_high;
    }
  }
  
  Widget _buildInstruction(String key, String action, ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.scaledEdgeInsets(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: responsive.scaledEdgeInsets(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              key,
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: responsive.smallFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          responsive.scaledSizedBox(width: 15),
          Text(
            action,
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.buttonFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

