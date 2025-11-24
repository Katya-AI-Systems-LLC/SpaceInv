# Sound Assets

This directory should contain the following sound files:

## Required Sounds

- ✅ `shoot.wav` - Sound effect for shooting (already exists)
- ⚠️ `explosion.wav` - Sound effect for enemy explosions (optional, will fallback to shoot.wav)
- ⚠️ `background.mp3` - Background music for the game (optional)

## Notes

- The game will work without these sound files - they are optional.
- If `explosion.wav` is not found, the game will use `shoot.wav` as a fallback.
- Background music is optional and will be skipped if not available.
- All sound files should be placed in this directory and referenced in `pubspec.yaml`.

## Adding Sound Files

You can add your own sound files:
1. Place the files in this directory
2. Ensure they are referenced in `pubspec.yaml` under `assets:`
3. The game will automatically use them if available

