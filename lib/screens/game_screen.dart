import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/player.dart';
import '../widgets/enemy.dart';
import '../widgets/bullet.dart';
import '../game_state.dart';
import '../collision_detection.dart';
import '../enemy_movement.dart';
import '../screens/game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState gameState;
  final FocusNode _focusNode = FocusNode();
  DateTime _lastUpdateTime = DateTime.now();
  double _lastEnemyShootTime = 0;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    _focusNode.requestFocus();
    _startGameLoop();
  }

  void _startGameLoop() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        _updateGame();
        if (!gameState.gameOver && !gameState.gameWon) {
          _startGameLoop();
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _updateGame() {
    if (gameState.isPaused || gameState.gameOver || gameState.gameWon) return;
    
    final now = DateTime.now();
    final deltaTime = (now.difference(_lastUpdateTime).inMilliseconds) / 1000.0;
    _lastUpdateTime = now;
    
    setState(() {
      gameState.gameTime += deltaTime;
      
      // Update player invulnerability
      gameState.player.updateInvulnerability(deltaTime);
      
      // Update enemy positions
      final screenWidth = MediaQuery.of(context).size.width;
      if (gameState.enemies.isNotEmpty) {
        enemyController.updateEnemyMovement(gameState.enemies, screenWidth);
      }
      
      // Update player bullets
      for (var bullet in gameState.bullets) {
        bullet.move();
      }
      gameState.bullets.removeWhere((bullet) => bullet.y < 0);
      
      // Update enemy bullets
      for (var bullet in gameState.enemyBullets) {
        bullet.move();
      }
      final screenHeight = MediaQuery.of(context).size.height;
      gameState.enemyBullets.removeWhere((bullet) => bullet.y > screenHeight);
      
      // Update particles
      for (var particle in gameState.particles) {
        particle.update();
      }
      gameState.particles.removeWhere((particle) => particle.life <= 0);
      
      // Enemy shooting
      _lastEnemyShootTime += deltaTime;
      if (_lastEnemyShootTime > 2.0 - (gameState.level * 0.1) && gameState.enemies.isNotEmpty) {
        _shootEnemyBullet();
        _lastEnemyShootTime = 0;
      }
      
      // Check collisions
      checkCollisions(gameState);
      
      // Check level complete
      if (gameState.enemies.isEmpty && !gameState.gameOver) {
        gameState.nextLevel();
      }
      
      // Check game over conditions
      if (gameState.gameOver || gameState.player.lives <= 0) {
        gameState.gameOver = true;
        _showGameOverScreen();
      }
    });
  }

  void _shootEnemyBullet() {
    if (gameState.enemies.isEmpty) return;
    
    // Randomly select a bottom enemy to shoot
    final aliveEnemies = gameState.enemies.where((e) => e.alive).toList();
    if (aliveEnemies.isEmpty) return;
    
    aliveEnemies.sort((a, b) => b.y.compareTo(a.y)); // Sort by y position (bottom first)
    final shooter = aliveEnemies[0];
    
    gameState.enemyBullets.add(Bullet(
      x: shooter.x + shooter.width / 2 - 2.5,
      y: shooter.y + shooter.height,
      isPlayerBullet: false,
    )..speed = 3 + gameState.level * 0.2);
  }

  void _fireBullet() {
    if (gameState.isPaused || gameState.gameOver || gameState.gameWon) return;
    
    setState(() {
      gameState.bullets.add(Bullet(
        x: gameState.player.x + gameState.player.width / 2 - 2.5,
        y: gameState.player.y,
        isPlayerBullet: true,
      ));
    });
  }

  void _togglePause() {
    setState(() {
      gameState.isPaused = !gameState.isPaused;
      if (!gameState.isPaused) {
        _lastUpdateTime = DateTime.now();
      }
    });
  }

  void _showGameOverScreen() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(
              score: gameState.score,
              level: gameState.level,
              isWin: gameState.gameWon,
              enemiesKilled: gameState.enemiesKilled,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              setState(() {
                gameState.player.x = (gameState.player.x - gameState.player.speed)
                    .clamp(0.0, screenWidth - gameState.player.width);
              });
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              setState(() {
                gameState.player.x = (gameState.player.x + gameState.player.speed)
                    .clamp(0.0, screenWidth - gameState.player.width);
              });
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _fireBullet();
            } else if (event.logicalKey == LogicalKeyboardKey.escape ||
                       event.logicalKey == LogicalKeyboardKey.keyP) {
              _togglePause();
            }
          }
        },
        child: GestureDetector(
          onTap: _fireBullet,
          onHorizontalDragUpdate: (details) {
            setState(() {
              gameState.player.x = (gameState.player.x + details.delta.dx)
                  .clamp(0.0, screenWidth - gameState.player.width);
            });
          },
          child: Stack(
            children: [
              // Background with stars
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black87],
                  ),
                ),
              ),
              // Starfield effect
              ...List.generate(50, (index) {
                final x = (index * 7.7) % screenWidth;
                final y = (index * 11.3) % screenHeight;
                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              
              // Particles
              ...gameState.particles.map((particle) => Positioned(
                    left: particle.x,
                    top: particle.y,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),
              
              // Enemies
              ...gameState.enemies.map((enemy) {
                if (!enemy.alive) return SizedBox.shrink();
                return Positioned(
                  top: enemy.y,
                  left: enemy.x,
                  child: EnemyWidget(enemy: enemy),
                );
              }),
              
              // Enemy bullets
              ...gameState.enemyBullets.map((bullet) => Positioned(
                    top: bullet.y,
                    left: bullet.x,
                    child: BulletWidget(bullet: bullet),
                  )),
              
              // Player bullets
              ...gameState.bullets.map((bullet) => Positioned(
                    top: bullet.y,
                    left: bullet.x,
                    child: BulletWidget(bullet: bullet),
                  )),
              
              // Player
              Positioned(
                bottom: 20,
                left: gameState.player.x,
                child: PlayerWidget(player: gameState.player),
              ),
              
              // UI Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score: ${gameState.score}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Level: ${gameState.level}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(3, (index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(
                                  index < gameState.player.lives
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: index < gameState.player.lives
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 24,
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'P: Pause',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Pause overlay
              if (gameState.isPaused)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PAUSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Press P to resume',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Invulnerability flash effect
              if (gameState.player.isInvulnerable &&
                  (gameState.player.invulnerableTime * 10).toInt() % 2 == 0)
                Positioned(
                  bottom: 20,
                  left: gameState.player.x,
                  child: Container(
                    width: gameState.player.width,
                    height: gameState.player.height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
