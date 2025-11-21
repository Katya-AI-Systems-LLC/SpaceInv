const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Audio context for sound effects
let audioContext;
try {
    audioContext = new (window.AudioContext || window.webkitAudioContext)();
} catch (e) {
    console.warn('Web Audio API not supported');
}

// Game variables
let player = {
    x: 175,
    y: 550,
    width: 50,
    height: 50,
    speed: 5,
    lives: 3,
    shield: false,
    shieldTime: 0,
    tripleShot: false,
    tripleShotTime: 0
};
let enemies = [];
let bullets = [];
let score = 0;
let gameOver = false;
let level = 1;
let enemySpeed = 1;
let bulletSpeed = 7;
let keys = {};
let particles = [];
let powerUps = [];
let highScore = localStorage.getItem('spaceInvadersHighScore') || 0;
let lastTime = 0;
let deltaTime = 0;
let gameStarted = false;
let paused = false;

// Initialize enemies
function initEnemies() {
    enemies = [];
    for (let row = 0; row < 5; row++) {
        for (let col = 0; col < 10; col++) {
            enemies.push({
                x: col * 35 + 20,
                y: row * 35 + 50,
                width: 25,
                height: 25,
                alive: true,
                type: Math.random() > 0.8 ? 'fast' : 'normal'
            });
        }
    }
}

// Draw functions
function drawPlayer() {
    ctx.fillStyle = '#00ff00';
    ctx.fillRect(player.x, player.y, player.width, player.height);
}

function drawEnemies() {
    enemies.forEach(enemy => {
        if (enemy.alive) {
            ctx.fillStyle = enemy.type === 'fast' ? '#ff0000' : '#ffff00';
            ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height);
        }
    });
}

function drawBullets() {
    ctx.fillStyle = '#ffffff';
    bullets.forEach(bullet => {
        ctx.fillRect(bullet.x, bullet.y, 3, 10);
    });
}

function drawParticles() {
    particles.forEach(particle => {
        ctx.fillStyle = particle.color;
        ctx.fillRect(particle.x, particle.y, 2, 2);
    });
}

function drawUI() {
    ctx.fillStyle = '#ffffff';
    ctx.font = '20px Arial';
    ctx.fillText(`Score: ${score}`, 10, 30);
    ctx.fillText(`Lives: ${player.lives}`, 10, 60);
    ctx.fillText(`Level: ${level}`, 10, 90);
    ctx.fillText(`High Score: ${highScore}`, 10, 120);

    if (gameOver) {
        ctx.fillStyle = '#ff0000';
        ctx.font = '48px Arial';
        ctx.fillText('GAME OVER', canvas.width / 2 - 120, canvas.height / 2);
        ctx.font = '24px Arial';
        ctx.fillText('Press R to Restart', canvas.width / 2 - 80, canvas.height / 2 + 50);
    }
}

// Game logic
function updatePlayer() {
    if (keys['ArrowLeft'] && player.x > 0) {
        player.x -= player.speed;
    }
    if (keys['ArrowRight'] && player.x < canvas.width - player.width) {
        player.x += player.speed;
    }
}

function updateEnemies(deltaTime) {
    let moveDown = false;
    enemies.forEach(enemy => {
        if (enemy.alive) {
            enemy.x += enemySpeed * deltaTime;
            if (enemy.x <= 0 || enemy.x >= canvas.width - enemy.width) {
                moveDown = true;
            }
        }
    });

    if (moveDown) {
        enemySpeed = -enemySpeed;
        enemies.forEach(enemy => {
            if (enemy.alive) {
                enemy.y += 20;
                if (enemy.y >= player.y) {
                    if (!player.shield) {
                        player.lives--;
                        if (player.lives <= 0) {
                            gameOver = true;
                        } else {
                            // Reset player position and give temporary shield
                            player.x = 175;
                            player.shield = true;
                            player.shieldTime = 3; // 3 seconds
                        }
                    }
                }
            }
        });
    }
}

function updateBullets() {
    bullets.forEach(bullet => {
        bullet.y -= bulletSpeed;
    });
    bullets = bullets.filter(bullet => bullet.y > 0);
}

function updateParticles() {
    particles.forEach(particle => {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.life--;
    });
    particles = particles.filter(particle => particle.life > 0);
}

function checkCollisions() {
    bullets.forEach(bullet => {
        enemies.forEach(enemy => {
            if (enemy.alive &&
                bullet.x < enemy.x + enemy.width &&
                bullet.x + 3 > enemy.x &&
                bullet.y < enemy.y + enemy.height &&
                bullet.y + 10 > enemy.y) {
                enemy.alive = false;
                bullets.splice(bullets.indexOf(bullet), 1);
                score += enemy.type === 'fast' ? 20 : 10;
                createExplosion(enemy.x + enemy.width / 2, enemy.y + enemy.height / 2);
            }
        });
    });
}

function createExplosion(x, y) {
    for (let i = 0; i < 10; i++) {
        particles.push({
            x: x,
            y: y,
            vx: (Math.random() - 0.5) * 4,
            vy: (Math.random() - 0.5) * 4,
            life: 30,
            color: '#ffff00'
        });
    }
}

function checkLevelComplete() {
    if (enemies.every(enemy => !enemy.alive)) {
        level++;
        enemySpeed += 0.5;
        initEnemies();
    }
}

function fireBullet() {
    bullets.push({ x: player.x + player.width / 2 - 1.5, y: player.y });
}

function gameLoop() {
    if (!gameOver) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        updatePlayer();
        updateEnemies();
        updateBullets();
        updateParticles();
        checkCollisions();
        checkLevelComplete();

        drawPlayer();
        drawEnemies();
        drawBullets();
        drawParticles();
        drawUI();
    } else {
        drawUI();
    }
}

// Event listeners
document.addEventListener('keydown', (e) => {
    keys[e.key] = true;
    if (e.key === ' ') {
        e.preventDefault();
        fireBullet();
    }
    if (e.key === 'r' && gameOver) {
        restartGame();
    }
});

document.addEventListener('keyup', (e) => {
    keys[e.key] = false;
});

canvas.addEventListener('touchstart', (e) => {
    e.preventDefault();
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    const x = touch.clientX - rect.left;
    player.x = x - player.width / 2;
    fireBullet();
});

canvas.addEventListener('touchmove', (e) => {
    e.preventDefault();
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    const x = touch.clientX - rect.left;
    player.x = Math.max(0, Math.min(canvas.width - player.width, x - player.width / 2));
});

function restartGame() {
    player.x = 175;
    player.lives = 3;
    score = 0;
    level = 1;
    enemySpeed = 1;
    gameOver = false;
    bullets = [];
    particles = [];
    initEnemies();
}

// Initialize canvas size
function resizeCanvas() {
    const container = document.getElementById('gameContainer');
    if (container) {
        const containerWidth = container.clientWidth;
        const containerHeight = container.clientHeight;
        canvas.width = Math.min(400, containerWidth - 20);
        canvas.height = Math.min(600, containerHeight - 100);
    }
}

// Setup canvas
if (canvas) {
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    // Initialize and start game
    initEnemies();
    requestAnimationFrame(function gameLoopRAF() {
        gameLoop();
        if (!gameOver) {
            requestAnimationFrame(gameLoopRAF);
        }
    });
} else {
    console.error('Canvas element not found!');
}

// Use requestAnimationFrame instead of setInterval for better performance
