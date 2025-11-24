import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/player.dart';
import '../widgets/enemy.dart';
import '../widgets/bullet.dart';
import '../widgets/power_up.dart';
import '../widgets/barrier.dart';
import '../game_state.dart';
import '../collision_detection.dart';
import '../enemy_movement.dart';
import '../game_over_conditions.dart';
import '../models/power_up.dart';
import '../models/game_mode.dart';
import '../models/run_modifier.dart';
import '../models/upgrade_type.dart';
import '../services/audio_service.dart';
import '../services/upgrades_service.dart';
import '../services/localization_service.dart';
import '../screens/game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final String? campaignMissionId;

  const GameScreen({super.key, this.mode = GameMode.classic, this.campaignMissionId});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState gameState;
  final FocusNode _focusNode = FocusNode();
  DateTime _lastUpdateTime = DateTime.now();
  double _lastEnemyShootTime = 0;
  final AudioService _audioService = AudioService();
  final math.Random _random = math.Random();
  int _lastPlayerLives = 3;
  double _shakeTime = 0;
  double _shakeIntensity = 0;
  double _bossIntroTime = 0;
  double _powerUpBannerTime = 0;
  IconData? _powerUpBannerIcon;
  String? _powerUpBannerLabel;
  double _comboBannerTime = 0;
  int _lastComboMultiplier = 1;

  static const double _basePlayerSpeed = 5;
  static const double _boostedPlayerSpeed = 8;

  @override
  void initState() {
    super.initState();
    gameState = GameState(mode: widget.mode);
    gameState.player.speed = _basePlayerSpeed;
    _lastPlayerLives = gameState.player.lives;
    if ((gameState.mode == GameMode.classic && gameState.level % 5 == 0) ||
        gameState.mode == GameMode.bossRush) {
      _bossIntroTime = 2.5;
    }
    _focusNode.requestFocus();
    _audioService.playBackgroundMusic();
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
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  void _updateGame() {
    if (gameState.isPaused || gameState.gameOver || gameState.gameWon) return;
    
    final now = DateTime.now();
    final deltaTime = (now.difference(_lastUpdateTime).inMilliseconds) / 1000.0;
    _lastUpdateTime = now;
    
    setState(() {
      gameState.gameTime += deltaTime;
      if (_shakeTime > 0) {
        _shakeTime -= deltaTime;
        if (_shakeTime < 0) _shakeTime = 0;
      }
      if (_bossIntroTime > 0) {
        _bossIntroTime -= deltaTime;
        if (_bossIntroTime < 0) _bossIntroTime = 0;
      }
      if (_powerUpBannerTime > 0) {
        _powerUpBannerTime -= deltaTime;
        if (_powerUpBannerTime < 0) _powerUpBannerTime = 0;
      }
      if (_comboBannerTime > 0) {
        _comboBannerTime -= deltaTime;
        if (_comboBannerTime < 0) _comboBannerTime = 0;
      }
      
      // Update player invulnerability
      gameState.player.updateInvulnerability(deltaTime);
      gameState.updateCombo(deltaTime);
      _updatePowerUpTimers(deltaTime);
      
      // Update enemy positions
      final screenWidth = MediaQuery.of(context).size.width;
      if (gameState.enemies.isNotEmpty) {
        enemyController.updateEnemyMovement(
          gameState.enemies,
          screenWidth,
          gameState.mode,
        );
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
      _updatePowerUps(screenHeight);
      
      // Update particles
      for (var particle in gameState.particles) {
        particle.update();
      }
      gameState.particles.removeWhere((particle) => particle.life <= 0);
      
      // Enemy shooting
      _lastEnemyShootTime += deltaTime;
      double interval = 2.0 - (gameState.level * 0.1);
      if (gameState.mode == GameMode.survival) {
        interval -= 0.2;
      } else if (gameState.mode == GameMode.hardcore) {
        interval -= 0.4;
      } else if (gameState.mode == GameMode.galacticRun) {
        final mod = gameState.currentModifier;
        if (mod == RunModifier.bulletHell) {
          interval -= 0.4;
        } else if (mod == RunModifier.fastEnemies) {
          interval -= 0.2;
        }
      }
      interval = interval.clamp(0.4, 3.0);

      if (_lastEnemyShootTime > interval && gameState.enemies.isNotEmpty) {
        _shootEnemyBullet();
        _lastEnemyShootTime = 0;
      }
      
      // Check collisions
      checkCollisions(
        gameState,
        audioService: _audioService,
        onEnemyDestroyed: _handleEnemyDestroyed,
      );
      
      // Check level complete
      if (gameState.enemies.isEmpty && !gameState.gameOver) {
        final nextLevel = gameState.level + 1;
        final willHaveBoss =
            (gameState.mode == GameMode.classic && nextLevel % 5 == 0) ||
                gameState.mode == GameMode.bossRush;
        gameState.nextLevel();
        if (willHaveBoss) {
          _bossIntroTime = 2.5;
        }
      }
      
      // Check game over conditions using the dedicated class
      if (GameOverConditions.checkGameOver(gameState)) {
        gameState.gameOver = true;
        _showGameOverScreen();
      }
      
      // Check if player won
      if (GameOverConditions.checkGameWon(gameState)) {
        gameState.gameWon = true;
        HapticFeedback.mediumImpact();
        _showGameOverScreen();
      }
      
      // Check if player was hit by enemy
      if (GameOverConditions.checkPlayerHitByEnemy(gameState)) {
        gameState.player.lives--;
        gameState.player.isInvulnerable = true;
        gameState.player.invulnerableTime = 2.0;
        if (gameState.player.lives <= 0) {
          gameState.gameOver = true;
          _showGameOverScreen();
        }
      }

      if (gameState.player.lives < _lastPlayerLives) {
        HapticFeedback.heavyImpact();
        _shakeTime = 0.35;
        _shakeIntensity = 10;
      }
      _lastPlayerLives = gameState.player.lives;

      // Trigger combo banner when multiplier grows
      if (gameState.comboMultiplier > 1 &&
          gameState.comboMultiplier > _lastComboMultiplier) {
        _comboBannerTime = 1.2;
      }
      _lastComboMultiplier = gameState.comboMultiplier;
    });
  }

  void _shootEnemyBullet() {
    if (gameState.enemies.isEmpty) return;
    
    // Randomly select a bottom enemy to shoot
    final aliveEnemies = gameState.enemies.where((e) => e.alive).toList();
    if (aliveEnemies.isEmpty) return;
    
    aliveEnemies.sort((a, b) => b.y.compareTo(a.y)); // Sort by y position (bottom first)
    final shooter = aliveEnemies[0];
    
    double baseX = shooter.x + shooter.width / 2 - 2.5;
    double speedBase = 3 + gameState.level * 0.2;
    if (gameState.mode == GameMode.survival) {
      speedBase += 0.4;
    } else if (gameState.mode == GameMode.hardcore) {
      speedBase += 0.8;
    } else if (gameState.mode == GameMode.galacticRun) {
      final mod = gameState.currentModifier;
      if (mod == RunModifier.fastEnemies) {
        speedBase += 0.6;
      } else if (mod == RunModifier.bulletHell) {
        speedBase += 0.4;
      }
    }

    gameState.enemyBullets.add(Bullet(
      x: baseX,
      y: shooter.y + shooter.height,
      isPlayerBullet: false,
    )..speed = speedBase);

    if (shooter.isBoss) {
      gameState.enemyBullets.add(Bullet(
        x: baseX - 15,
        y: shooter.y + shooter.height,
        isPlayerBullet: false,
      )..speed = speedBase + 0.5);
      gameState.enemyBullets.add(Bullet(
        x: baseX + 15,
        y: shooter.y + shooter.height,
        isPlayerBullet: false,
      )..speed = speedBase + 0.5);

      // Second phase: when boss health is low, fire additional wider spread
      final int phaseThreshold = (20 + gameState.level * 2) ~/ 2;
      if (shooter.health <= phaseThreshold) {
        gameState.enemyBullets.add(Bullet(
          x: baseX - 30,
          y: shooter.y + shooter.height,
          isPlayerBullet: false,
        )..speed = speedBase + 0.2);
        gameState.enemyBullets.add(Bullet(
          x: baseX + 30,
          y: shooter.y + shooter.height,
          isPlayerBullet: false,
        )..speed = speedBase + 0.2);
      }
    }
  }

  void _fireBullet() {
    if (gameState.isPaused || gameState.gameOver || gameState.gameWon) return;
    
    setState(() {
      final baseX = gameState.player.x + gameState.player.width / 2 - 2.5;
      gameState.bullets.add(_createPlayerBullet(baseX));

      if (gameState.hasMultiShot) {
        gameState.bullets.add(_createPlayerBullet(baseX - 14));
        gameState.bullets.add(_createPlayerBullet(baseX + 14));
      }
    });
    _audioService.playShootSound();
  }

  Bullet _createPlayerBullet(double x) {
    return Bullet(
      x: _clampBulletX(x),
      y: gameState.player.y,
      isPlayerBullet: true,
    );
  }

  double _clampBulletX(double x) {
    final screenWidth = MediaQuery.of(context).size.width;
    return x.clamp(0.0, screenWidth - 5).toDouble();
  }

  void _updatePowerUpTimers(double deltaTime) {
    if (gameState.multiShotTime > 0) {
      gameState.multiShotTime -= deltaTime;
      if (gameState.multiShotTime <= 0) {
        gameState.multiShotTime = 0;
      }
    }

    if (gameState.speedBoostTime > 0) {
      gameState.speedBoostTime -= deltaTime;
      if (gameState.speedBoostTime <= 0) {
        gameState.speedBoostTime = 0;
        gameState.player.speed = _basePlayerSpeed;
      }
    }
  }

  void _updatePowerUps(double screenHeight) {
    for (var powerUp in gameState.powerUps) {
      powerUp.move();
    }

    gameState.powerUps.removeWhere((powerUp) {
      if (powerUp.y > screenHeight) {
        return true;
      }

      final collected = checkRectCollision(
        powerUp.x,
        powerUp.y,
        powerUp.width,
        powerUp.height,
        gameState.player.x,
        gameState.player.y,
        gameState.player.width,
        gameState.player.height,
      );

      if (collected) {
        _applyPowerUp(powerUp);
        return true;
      }
      return false;
    });
  }

  void _applyPowerUp(PowerUp powerUp) {
    _audioService.playPowerUpSound();
    HapticFeedback.lightImpact();
    _powerUpBannerTime = 1.5;
    final loc = LocalizationService();
    String baseLabel;
    switch (powerUp.type) {
      case PowerUpType.multiShot:
        gameState.multiShotTime = 8;
        _powerUpBannerIcon = Icons.auto_awesome;
        baseLabel = loc.t('powerup_multi_shot');
        break;
      case PowerUpType.shield:
        final level = UpgradesService().getLevel(UpgradeType.shieldStrength);
        double duration = 4 + level.toDouble();
        gameState.player.isInvulnerable = true;
        gameState.player.invulnerableTime = duration;
        _powerUpBannerIcon = Icons.shield;
        baseLabel = loc.t('powerup_shield');
        break;
      case PowerUpType.speedBoost:
        gameState.speedBoostTime = 6;
        gameState.player.speed = _boostedPlayerSpeed;
        _powerUpBannerIcon = Icons.speed;
        baseLabel = loc.t('powerup_speed_boost');
        break;
      case PowerUpType.lifeUp:
        gameState.player.lives = (gameState.player.lives + 1).clamp(0, 5);
        _powerUpBannerIcon = Icons.favorite;
        baseLabel = loc.t('powerup_extra_life');
        break;
    }

    String prefix = '';
    switch (gameState.mode) {
      case GameMode.bossRush:
        prefix = loc.t('powerup_prefix_rush');
        break;
      case GameMode.galacticRun:
        prefix = loc.t('powerup_prefix_run');
        break;
      case GameMode.hardcore:
        prefix = loc.t('powerup_prefix_hard');
        break;
      case GameMode.classic:
      case GameMode.survival:
        prefix = '';
        break;
    }
    _powerUpBannerLabel = '$prefix$baseLabel';
  }

  void _handleEnemyDestroyed(Enemy enemy) {
    double dropChance = enemy.isBoss ? 0.9 : 0.25;
    if (gameState.mode == GameMode.galacticRun &&
        gameState.currentModifier == RunModifier.richDrops) {
      dropChance = enemy.isBoss ? 1.0 : 0.6;
    }
    final dropLevel = UpgradesService().getLevel(UpgradeType.dropChance);
    if (dropLevel > 0) {
      dropChance += 0.08 * dropLevel;
      if (dropChance > 1.0) {
        dropChance = 1.0;
      }
    }
    if (_random.nextDouble() > dropChance) return;

    final type = PowerUp.getRandomType();
    gameState.powerUps.add(PowerUp(
      x: enemy.x + enemy.width / 2 - 15,
      y: enemy.y,
      type: type,
    ));
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
        _audioService.stopBackgroundMusic();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(
              score: gameState.score,
              level: gameState.level,
              isWin: gameState.gameWon,
              enemiesKilled: gameState.enemiesKilled,
              mode: gameState.mode,
              campaignMissionId: widget.campaignMissionId,
            ),
          ),
        );
      }
    });
  }

  Widget _buildPowerBadge(IconData icon, String label, double remainingSeconds) {
    final double clamped = remainingSeconds.clamp(0.0, 999.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white30,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amberAccent, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label (${clamped.toStringAsFixed(1)}s)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double time = gameState.gameTime;
    final loc = LocalizationService();
    Enemy? currentBoss;
    for (final e in gameState.enemies) {
      if (e.isBoss && e.alive) {
        currentBoss = e;
        break;
      }
    }
    final bool hasBoss =
        currentBoss != null && gameState.bossMaxHealth > 0;
    double bossHealthRatio = hasBoss
        ? currentBoss!.health / gameState.bossMaxHealth
        : 0;
    if (bossHealthRatio < 0) bossHealthRatio = 0;
    if (bossHealthRatio > 1) bossHealthRatio = 1;

    Offset shakeOffset = Offset.zero;
    if (_shakeTime > 0) {
      final double mag = _shakeIntensity * (_shakeTime / 0.35);
      final dx = (_random.nextDouble() * 2 - 1) * mag;
      final dy = (_random.nextDouble() * 2 - 1) * mag;
      shakeOffset = Offset(dx, dy);
    }

    Color powerBannerColor;
    switch (gameState.mode) {
      case GameMode.classic:
        powerBannerColor = Colors.amberAccent;
        break;
      case GameMode.survival:
        powerBannerColor = Colors.lightBlueAccent;
        break;
      case GameMode.hardcore:
        powerBannerColor = Colors.redAccent;
        break;
      case GameMode.galacticRun:
        powerBannerColor = Colors.greenAccent;
        break;
      case GameMode.bossRush:
        powerBannerColor = Colors.deepOrangeAccent;
        break;
    }

    Color comboColor;
    switch (gameState.comboMultiplier) {
      case 2:
        comboColor = Colors.lightBlueAccent;
        break;
      case 3:
        comboColor = Colors.greenAccent;
        break;
      case 4:
        comboColor = Colors.orangeAccent;
        break;
      case 5:
      default:
        comboColor = Colors.redAccent;
        break;
    }
    
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
              
              // Barriers
              ...gameState.barriers.map((barrier) => Positioned(
                    top: barrier.y,
                    left: barrier.x,
                    child: BarrierWidget(barrier: barrier),
                  )),
              
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
                final double pulse = 1.0 +
                    (enemy.isBoss ? 0.12 : 0.06) *
                        math.sin(time * 4 + enemy.x * 0.1);
                return Positioned(
                  top: enemy.y,
                  left: enemy.x,
                  child: Transform.scale(
                    scale: pulse,
                    child: EnemyWidget(enemy: enemy),
                  ),
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
              
              // Power-ups
              ...gameState.powerUps.map((powerUp) {
                final double bobOffset =
                    3 * math.sin(time * 4 + powerUp.x * 0.2);
                return Positioned(
                  top: powerUp.y + bobOffset,
                  left: powerUp.x,
                  child: PowerUpWidget(powerUp: powerUp),
                );
              }),
              
              // Player
              Positioned(
                bottom: 20,
                left: gameState.player.x,
                child: Transform.translate(
                  offset: Offset(0, math.sin(time * 5) * 2),
                  child: PlayerWidget(player: gameState.player, time: time),
                ),
              ),
              
              // UI Overlay
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Score: ${gameState.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level: ${gameState.level}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            if (gameState.mode == GameMode.galacticRun &&
                                gameState.currentModifier != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Modifier: ${gameState.currentModifier!.label}',
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (gameState.hasCombo) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Combo x${gameState.comboMultiplier}',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            if (hasBoss) ...[
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: bossHealthRatio,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.redAccent,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: List.generate(3, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(right: 4),
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
                            const SizedBox(height: 4),
                            const Text(
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
                    if (gameState.hasMultiShot ||
                        gameState.hasSpeedBoost ||
                        gameState.player.isInvulnerable)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (gameState.hasMultiShot)
                              _buildPowerBadge(
                                Icons.auto_awesome,
                                'Multi-Shot',
                                gameState.multiShotTime,
                              ),
                            if (gameState.hasSpeedBoost)
                              _buildPowerBadge(
                                Icons.speed,
                                'Speed',
                                gameState.speedBoostTime,
                              ),
                            if (gameState.player.isInvulnerable)
                              _buildPowerBadge(
                                Icons.shield,
                                'Shield',
                                gameState.player.invulnerableTime,
                              ),
                          ],
                        ),
                      ),
                  ],
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
              
              if (gameState.isPaused)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                ),
              if (_comboBannerTime > 0 && gameState.comboMultiplier > 1)
                Positioned(
                  top: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity:
                          (_comboBannerTime / 1.2).clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: comboColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.whatshot,
                              color: Colors.orangeAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc
                                  .t('combo_banner')
                                  .replaceFirst(
                                      '{x}',
                                      gameState.comboMultiplier
                                          .toString()),
                              style: TextStyle(
                                color: comboColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_powerUpBannerTime > 0 &&
                  _powerUpBannerIcon != null &&
                  _powerUpBannerLabel != null)
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity:
                          (_powerUpBannerTime / 1.5).clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: powerBannerColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _powerUpBannerIcon,
                              color: powerBannerColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _powerUpBannerLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
