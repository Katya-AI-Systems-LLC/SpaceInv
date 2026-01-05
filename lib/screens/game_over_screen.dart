 import 'package:flutter/material.dart';
 import 'package:shared_preferences/shared_preferences.dart';
 import '../services/statistics_service.dart';
 import '../services/achievements_service.dart';
 import '../services/leaderboard_service.dart';
 import '../services/localization_service.dart';
 import '../services/campaign_service.dart';
 import '../services/currency_service.dart';
 import '../services/ai_director_service.dart';
 import '../services/web3_bridge_service.dart';
 import '../models/game_mode.dart';
 import 'start_menu_screen.dart';
 import 'game_screen.dart';
 import '../utils/responsive_helper.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int level;
  final bool isWin;
  final int enemiesKilled;
  final GameMode mode;
  final String? campaignMissionId;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.level,
    required this.isWin,
    this.enemiesKilled = 0,
    this.mode = GameMode.classic,
    this.campaignMissionId,
  });

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  int? highScore;
  bool isNewHighScore = false;
  final StatisticsService _statisticsService = StatisticsService();
  final AchievementsService _achievementsService = AchievementsService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  final CampaignService _campaignService = CampaignService();
  bool _missionCompleted = false;
  final CurrencyService _currencyService = CurrencyService();
  int? _creditsEarned;
  int? _creditsTotal;
  late ResponsiveHelper _responsive;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _saveStatistics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _responsive = ResponsiveHelper();
    _responsive.initialize(context);
  }

  Future<void> _updateCredits() async {
    try {
      final earned = await _currencyService.addCreditsForGame(
        score: widget.score,
        level: widget.level,
        enemiesKilled: widget.enemiesKilled,
        won: widget.isWin,
      );
      final total = await _currencyService.getCredits();
      if (!mounted) return;
      setState(() {
        _creditsEarned = earned;
        _creditsTotal = total;
      });
    } catch (_) {}
  }

  Future<void> _saveStatistics() async {
    await _statisticsService.recordGame(
      score: widget.score,
      level: widget.level,
      enemiesKilled: widget.enemiesKilled,
      won: widget.isWin,
    );
    await _achievementsService.updateAchievementsOnGameEnd(
      score: widget.score,
      level: widget.level,
      enemiesKilled: widget.enemiesKilled,
      won: widget.isWin,
      mode: widget.mode,
    );
    await _leaderboardService.addEntry(
      score: widget.score,
      level: widget.level,
      mode: widget.mode,
    );
    await AiDirectorService().sendGameSummary(
      score: widget.score,
      level: widget.level,
      enemiesKilled: widget.enemiesKilled,
      won: widget.isWin,
      mode: widget.mode,
    );
    await Web3BridgeService().sendGameResultProof(
      score: widget.score,
      level: widget.level,
      enemiesKilled: widget.enemiesKilled,
      won: widget.isWin,
      mode: widget.mode,
    );
    await _updateCampaignProgress();
    await _updateCredits();
  }

  Future<void> _updateCampaignProgress() async {
    if (widget.campaignMissionId == null) {
      return;
    }
    final completed = await _campaignService.onGameFinished(
      missionId: widget.campaignMissionId!,
      level: widget.level,
      score: widget.score,
      enemiesKilled: widget.enemiesKilled,
      mode: widget.mode,
      won: widget.isWin,
    );
    if (!mounted || !completed) return;
    setState(() {
      _missionCompleted = true;
    });
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHighScore = prefs.getInt('high_score') ?? 0;
      setState(() {
        highScore = savedHighScore;
        if (widget.score > savedHighScore) {
          isNewHighScore = true;
          prefs.setInt('high_score', widget.score);
          highScore = widget.score;
        }
      });
    } catch (e) {
      // Shared preferences not available
      setState(() {
        highScore = widget.score;
        isNewHighScore = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isWin
                ? [Colors.black, Colors.green.shade900]
                : [Colors.black, Colors.red.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Over / Victory text
              Text(
                widget.isWin
                    ? loc.t('title_victory')
                    : loc.t('title_game_over'),
                style: TextStyle(
                  color: widget.isWin ? Colors.greenAccent : Colors.redAccent,
                  fontSize: _responsive.titleFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: widget.isWin ? Colors.greenAccent : Colors.redAccent,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              _responsive.scaledSizedBox(height: 40),
              
              // Score
              Container(
                padding: _responsive.screenPadding,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    if (isNewHighScore)
                      Container(
                        padding: _responsive.scaledEdgeInsets(horizontal: 15, vertical: 8),
                        margin: _responsive.scaledEdgeInsets(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'NEW HIGH SCORE!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: _responsive.buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    _buildStatRow(loc.t('lbl_score'), widget.score.toString()),
                    _responsive.scaledSizedBox(height: 10),
                    _buildStatRow(loc.t('lbl_level'), widget.level.toString()),
                    if (highScore != null) ...[
                      _responsive.scaledSizedBox(height: 10),
                      _buildStatRow(loc.t('lbl_high_score'), '$highScore'),
                    ],
                    if (_creditsEarned != null && _creditsEarned! > 0) ...[
                      _responsive.scaledSizedBox(height: 10),
                      _buildStatRow(
                        loc.t('lbl_credits_earned'),
                        '+$_creditsEarned',
                      ),
                      if (_creditsTotal != null) ...[
                        _responsive.scaledSizedBox(height: 6),
                        _buildStatRow(
                          loc.t('lbl_credits_total'),
                          '$_creditsTotal',
                        ),
                      ],
                    ],
                    if (_missionCompleted) ...[
                      _responsive.scaledSizedBox(height: 10),
                      Container(
                        padding: _responsive.scaledEdgeInsets(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: Text(
                          loc.t('campaign_mission_complete'),
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: _responsive.buttonFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _responsive.scaledSizedBox(height: 40),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(mode: widget.mode),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: _responsive.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_responsive.buttonBorderRadius),
                      ),
                    ),
                    child: Text(
                      loc.t('btn_play_again'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _responsive.buttonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _responsive.scaledSizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StartMenuScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: _responsive.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_responsive.buttonBorderRadius),
                      ),
                    ),
                    child: Text(
                      loc.t('btn_menu'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _responsive.buttonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_missionCompleted && _hasNextMission()) ...[
                    _responsive.scaledSizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _startNextCampaignMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: _responsive.buttonPadding,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_responsive.buttonBorderRadius),
                        ),
                      ),
                      child: Text(
                        loc.t('btn_next_mission'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _responsive.buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: _responsive.uiFontSize,
          ),
        ),
        _responsive.scaledSizedBox(width: 20),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: _responsive.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _hasNextMission() {
    final id = widget.campaignMissionId;
    if (id == null) return false;
    final missions = _campaignService.missions;
    final index = missions.indexWhere((m) => m.id == id);
    return index != -1 && index + 1 < missions.length;
  }

  void _startNextCampaignMission() {
    final id = widget.campaignMissionId;
    if (id == null) return;
    final missions = _campaignService.missions;
    final index = missions.indexWhere((m) => m.id == id);
    if (index == -1 || index + 1 >= missions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartMenuScreen()),
      );
      return;
    }
    final next = missions[index + 1];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          mode: next.mode,
          campaignMissionId: next.id,
        ),
      ),
    );
  }
}

