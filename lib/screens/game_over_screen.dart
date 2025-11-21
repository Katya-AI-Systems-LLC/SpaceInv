import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/statistics_service.dart';
import 'start_menu_screen.dart';
import 'game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int level;
  final bool isWin;
  final int enemiesKilled;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.level,
    required this.isWin,
    this.enemiesKilled = 0,
  });

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  int? highScore;
  bool isNewHighScore = false;
  final StatisticsService _statisticsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _saveStatistics();
  }

  Future<void> _saveStatistics() async {
    await _statisticsService.recordGame(
      score: widget.score,
      level: widget.level,
      enemiesKilled: widget.enemiesKilled,
      won: widget.isWin,
    );
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
                widget.isWin ? 'VICTORY!' : 'GAME OVER',
                style: TextStyle(
                  color: widget.isWin ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 56,
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
              SizedBox(height: 40),
              
              // Score
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    if (isNewHighScore)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'NEW HIGH SCORE!',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    _buildStatRow('Score', widget.score.toString()),
                    SizedBox(height: 10),
                    _buildStatRow('Level', widget.level.toString()),
                    if (highScore != null) ...[
                      SizedBox(height: 10),
                      _buildStatRow('High Score', '$highScore'),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 40),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const StartMenuScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'MENU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
            fontSize: 20,
          ),
        ),
        SizedBox(width: 20),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

