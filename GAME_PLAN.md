# Space Invaders Game Plan

## Step 1: Project Setup
- [ ] Set up a new Flutter project using `flutter create space_invaders`.
- [ ] Initialize a new Git repository using `git init`.
- [ ] Configure the .gitignore file for Flutter projects.
  - [ ] Add common Flutter and Dart files to .gitignore.
  - [ ] Example: `build/`, `*.iml`, `*.log`, `*.tmp`, `*.DS_Store`, `*.idea/`, `*.vscode/`.

## Step 2: Game Assets
- [ ] Create or source the necessary game assets (images, sounds).
  - [ ] Create player sprite (spaceship) in `assets/images/player.png`.
  - [ ] Create enemy sprite (alien) in `assets/images/enemy.png`.
  - [ ] Create bullet sprite in `assets/images/bullet.png`.
  - [ ] Source background music in `assets/sounds/background.mp3`.
  - [ ] Source sound effects for shooting and collisions in `assets/sounds/`.
- [ ] Organize assets into appropriate directories:
  - [ ] Create `assets/images` directory for sprites.
  - [ ] Create `assets/sounds` directory for audio files.

## Step 3: Game UI
- [ ] Design the game UI using Flutter widgets.
  - [ ] Create a `GameScreen` widget in `lib/screens/game_screen.dart`.
    - [ ] Use `Stack` widget to layer game elements.
    - [ ] Use `Positioned` widget to position elements on the screen.
  - [ ] Add a `Player` widget to the `GameScreen`.
    - [ ] Implement player widget in `lib/widgets/player.dart`.
    - [ ] Use `Image.asset` to load and display player sprite.
    - [ ] Implement touch and keyboard input handling.
    - [ ] Example: Use `GestureDetector` for touch inputs and `RawKeyboardListener` for keyboard inputs.
  - [ ] Add `Enemy` widgets to the `GameScreen`.
    - [ ] Implement enemy widget in `lib/widgets/enemy.dart`.
    - [ ] Use `Image.asset` to load and display enemy sprite.
    - [ ] Implement enemy movement patterns.
    - [ ] Example: Enemies move horizontally and vertically in waves.
  - [ ] Add `Bullet` widgets to the `GameScreen`.
    - [ ] Implement bullet widget in `lib/widgets/bullet.dart`.
    - [ ] Use `Image.asset` to load and display bullet sprite.
    - [ ] Implement bullet firing mechanics.
    - [ ] Example: Bullets move upwards at a constant speed.
- [ ] Implement the game screen layout.
  - [ ] Set up a grid layout for enemies using `GridView`.
  - [ ] Position the player at the bottom of the screen using `Align` widget.
  - [ ] Example: Use `GridView.builder` to create a grid of enemies.
- [ ] Add the player, enemy, and bullet sprites to the game screen.
  - [ ] Load and display player sprite using `Image.asset`.
  - [ ] Load and display enemy sprites using `Image.asset`.
  - [ ] Load and display bullet sprites using `Image.asset`.
  - [ ] Example: Use `Image.asset('assets/images/player.png')` to load the player sprite.

## Step 4: Game Logic
- [ ] Implement player movement using touch or keyboard inputs.
  - [ ] Handle touch events for player movement using `GestureDetector`.
  - [ ] Handle keyboard events for player movement using `RawKeyboardListener`.
  - [ ] Example: Update player position based on touch or keyboard input.
  - [ ] Use `setState` to update player position.
- [ ] Implement enemy movement patterns.
  - [ ] Create a pattern for enemy movement in `lib/enemy_movement.dart`.
  - [ ] Implement enemy movement in the `Enemy` widget using the created pattern.
  - [ ] Example: Enemies move horizontally and vertically in waves.
  - [ ] Use `AnimationController` and `Tween` for smooth movement.
- [ ] Implement bullet firing mechanics.
  - [ ] Create a method to fire bullets in `lib/player.dart`.
  - [ ] Implement bullet movement in the `Bullet` widget using `AnimationController`.
  - [ ] Example: Bullets move upwards at a constant speed.
  - [ ] Use `setState` to update bullet position.
- [ ] Implement collision detection between bullets and enemies.
  - [ ] Create a method to detect collisions in `lib/collision_detection.dart`.
  - [ ] Update game state when a collision occurs.
  - [ ] Example: Remove enemy and bullet when they collide.
  - [ ] Use `Rect` and `contains` methods for collision detection.
- [ ] Implement scoring system.
  - [ ] Create a variable to store the score in `lib/game_state.dart`.
  - [ ] Update the score when an enemy is hit.
  - [ ] Example: Increase score by 10 points for each enemy hit.
  - [ ] Use `setState` to update the score display.
- [ ] Implement game over conditions.
  - [ ] Create a method to check for game over conditions in `lib/game_over_conditions.dart`.
  - [ ] Display a game over screen when conditions are met.
  - [ ] Example: Game over when player is hit by an enemy.
  - [ ] Use `Navigator` to navigate to a game over screen.

## Step 5: Web Version
- [ ] Create a web version of the game using HTML, CSS, and JavaScript.
  - [ ] Create `index.html` file in `web/`.
    - [ ] Include necessary HTML structure.
    - [ ] Link `styles.css` and `game.js` files.
    - [ ] Example: 
      ```html
      <!DOCTYPE html>
      <html>
      <head>
        <link rel="stylesheet" href="styles.css">
      </head>
      <body>
        <canvas id="gameCanvas"></canvas>
        <script src="game.js"></script>
      </body>
      </html>
      ```
  - [ ] Create `styles.css` file in `web/`.
    - [ ] Style the game screen.
    - [ ] Style the player, enemy, and bullet sprites.
    - [ ] Example: 
      ```css
      body {
        margin: 0;
        overflow: hidden;
      }
      #gameCanvas {
        background-color: black;
        display: block;
      }
      ```
  - [ ] Create `game.js` file in `web/`.
    - [ ] Implement game logic in JavaScript.
    - [ ] Handle player movement using keyboard inputs.
    - [ ] Implement enemy movement patterns.
    - [ ] Implement bullet firing mechanics.
    - [ ] Implement collision detection between bullets and enemies.
    - [ ] Implement scoring system.
    - [ ] Implement game over conditions.
    - [ ] Example: 
      ```javascript
      const canvas = document.getElementById('gameCanvas');
      const ctx = canvas.getContext('2d');
      // Game logic implementation
      ```
    - [ ] Use `requestAnimationFrame` for smooth animation.
    - [ ] Use `addEventListener` for keyboard input handling.
    - [ ] Initialize game variables.
    - [ ] Create player object with properties like position, speed, and sprite.
    - [ ] Create enemy object with properties like position, speed, and sprite.
    - [ ] Create bullet object with properties like position, speed, and sprite.
    - [ ] Implement player movement logic.
    - [ ] Implement enemy movement logic.
    - [ ] Implement bullet firing logic.
    - [ ] Implement collision detection logic.
    - [ ] Implement scoring logic.
    - [ ] Implement game over logic.

## Step 6: Testing
- [ ] Test the game on different devices and browsers.
  - [ ] Test on Android and iOS devices using `flutter run`.
  - [ ] Test on various web browsers using `flutter run -d chrome`.
  - [ ] Example: Test on multiple devices using `flutter devices` and `flutter run -d <device_id>`.
- [ ] Fix any bugs found during testing.
  - [ ] Example: Use `flutter analyze` to find potential issues.
  - [ ] Example: Use `flutter test` to run unit tests.

## Step 7: Deployment
- [ ] Deploy the Flutter app to the app stores.
  - [ ] Build the app using `flutter build apk` and `flutter build ios`.
  - [ ] Upload the app to Google Play Store and Apple App Store.
  - [ ] Example: Use `flutter build apk` and `flutter build ios` to generate build files.
  - [ ] Use `flutter pub get` to ensure all dependencies are up to date.
- [ ] Deploy the web version to a web server or hosting service.
  - [ ] Build the web version using `flutter build web`.
  - [ ] Upload the web version to a hosting service like GitHub Pages or Firebase Hosting.
  - [ ] Example: Use `gh-pages` to deploy the web version to GitHub Pages.
  - [ ] Example: Use Firebase Hosting to deploy the web version.
