import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 0.5;
  
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  Future<void> initialize() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _soundVolume = prefs.getDouble('sound_volume') ?? 1.0;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
    } catch (e) {
      // Use defaults if prefs not available
    }
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('music_enabled', _musicEnabled);
      await prefs.setDouble('sound_volume', _soundVolume);
      await prefs.setDouble('music_volume', _musicVolume);
    } catch (e) {
      // Ignore if prefs not available
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_musicVolume);
      // Note: Add background.mp3 to assets/sounds/ to enable
      // await _backgroundPlayer.play(AssetSource('sounds/background.mp3'));
    } catch (e) {
      // Background music file not found, skip silently
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
  }

  Future<void> playShootSound() async {
    if (!_soundEnabled) return;
    try {
      await _soundEffectPlayer.setVolume(_soundVolume);
      await _soundEffectPlayer.play(AssetSource('sounds/shoot.wav'));
    } catch (e) {
      // Sound file not found, skip silently
    }
  }

  Future<void> playExplosionSound() async {
    if (!_soundEnabled) return;
    try {
      await _soundEffectPlayer.setVolume(_soundVolume);
      // Reuse shoot sound for explosion if explosion sound not available
      await _soundEffectPlayer.play(AssetSource('sounds/shoot.wav'));
    } catch (e) {
      // Sound file not found, skip silently
    }
  }

  Future<void> playPowerUpSound() async {
    if (!_soundEnabled) return;
    try {
      await _soundEffectPlayer.setVolume(_soundVolume);
      await _soundEffectPlayer.play(AssetSource('sounds/shoot.wav'));
    } catch (e) {
      // Sound file not found, skip silently
    }
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    saveSettings();
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    saveSettings();
    if (!enabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    saveSettings();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _backgroundPlayer.setVolume(_musicVolume);
    saveSettings();
  }

  void dispose() {
    _backgroundPlayer.dispose();
    _soundEffectPlayer.dispose();
  }
}

