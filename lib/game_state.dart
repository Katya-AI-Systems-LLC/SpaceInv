class Player {
  double x = 200;
  double y = 500;
  double speed = 5;
  double width = 50;
  double height = 50;
  int lives = 3;
  bool isInvulnerable = false;
  double invulnerableTime = 0;
  
  void updateInvulnerability(double deltaTime) {
    if (isInvulnerable) {
      invulnerableTime -= deltaTime;
      if (invulnerableTime <= 0) {
        isInvulnerable = false;
      }
    }
  }
}

class Enemy {
  double x;
  double y;
  double speed = 1;
  double width = 40;
  double height = 40;
  bool alive = true;
  int type = 0; // 0 = normal, 1 = fast, 2 = strong
  
  Enemy({required this.x, required this.y, this.type = 0}) {
    if (type == 1) speed = 1.5;
    if (type == 2) speed = 0.8;
  }
}

class Bullet {
  double x;
  double y;
  double speed = 10;
  double width = 5;
  double height = 15;
  bool isPlayerBullet = true;

  Bullet({required this.x, required this.y, this.isPlayerBullet = true});

  void move() {
    if (isPlayerBullet) {
      y -= speed;
    } else {
      y += speed;
    }
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  int life;
  double size;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.life = 30,
    this.size = 3,
  });
  
  void update() {
    x += vx;
    y += vy;
    life--;
  }
}

class GameState {
  Player player = Player();
  List<Enemy> enemies = [];
  List<Bullet> bullets = [];
  List<Bullet> enemyBullets = [];
  List<Particle> particles = [];
  int score = 0;
  int level = 1;
  bool gameOver = false;
  bool isPaused = false;
  bool gameWon = false;
  double lastEnemyShootTime = 0;
  double gameTime = 0;
  int enemiesKilled = 0; // Track killed enemies for statistics

  GameState() {
    initLevel();
  }
  
  void initLevel() {
    enemies.clear();
    bullets.clear();
    enemyBullets.clear();
    particles.clear();
    
    // Initialize enemies in a grid
    int enemyRows = 3 + (level ~/ 2);
    int enemyCols = 8 + (level ~/ 3);
    
    for (int row = 0; row < enemyRows; row++) {
      for (int col = 0; col < enemyCols; col++) {
        int type = 0;
        if (row == 0 && (col % 3 == 0)) type = 1; // Fast enemies
        if (row == enemyRows - 1 && (col % 4 == 0)) type = 2; // Strong enemies
        
        enemies.add(Enemy(
          x: col * 45.0 + 30,
          y: row * 45.0 + 50,
          type: type,
        )..speed = (1 + level * 0.2));
      }
    }
  }
  
  void nextLevel() {
    level++;
    player.x = 200;
    player.isInvulnerable = true;
    player.invulnerableTime = 2.0;
    initLevel();
  }
}
