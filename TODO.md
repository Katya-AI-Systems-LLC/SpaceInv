# Space Invaders Game Implementation TODO

## Step 1: Update pubspec.yaml for assets
- Add assets section to pubspec.yaml for images and sounds.

## Step 2: Create assets directories and placeholders
- Create assets/images/ directory.
- Create assets/sounds/ directory.
- Add placeholder files (e.g., simple colored rectangles for images, empty for sounds).

## Step 3: Replace main.dart with game app structure
- Update main.dart to launch the game instead of counter app.

## Step 4: Create game screen
- Create lib/screens/game_screen.dart with Stack and Positioned for game elements.

## Step 5: Create player widget
- Create lib/widgets/player.dart with Image.asset, GestureDetector for touch, RawKeyboardListener for keyboard.

## Step 6: Create enemy widget
- Create lib/widgets/enemy.dart with Image.asset and movement logic.

## Step 7: Create bullet widget
- Create lib/widgets/bullet.dart with Image.asset and firing/movement.

## Step 8: Implement game logic
- Create lib/game_state.dart for score and state.
- Create lib/collision_detection.dart for bullet-enemy collisions.
- Create lib/enemy_movement.dart for enemy patterns.
- Create lib/game_over_conditions.dart for game over logic.
- Integrate movement, collision, scoring, game over into game screen.

## Step 9: Implement web version
- Update web/index.html with canvas.
- Create web/styles.css for styling.
- Create web/game.js with JavaScript game logic.

## Step 10: Testing
- Run flutter run on Android/iOS.
- Run flutter run -d chrome for web.
- Fix bugs with flutter analyze.

## Step 11: Deployment
- Build APK with flutter build apk.
- Build iOS with flutter build ios.
- Build web with flutter build web.
- Deploy to stores/hosting.
