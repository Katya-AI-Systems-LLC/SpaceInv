import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:space_invaders/services/audio_service.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final audioService = AudioService();
  late _MockAudioPlayer bgPlayer;
  late _MockAudioPlayer sfxPlayer;

  setUp(() {
    bgPlayer = _MockAudioPlayer();
    sfxPlayer = _MockAudioPlayer();
    audioService.configureAudioPlayersForTesting(
      backgroundPlayer: bgPlayer,
      soundEffectPlayer: sfxPlayer,
    );
    audioService.resetForTesting();
  });

  test('playBackgroundMusic triggers looping playback', () async {
    when(() => bgPlayer.setReleaseMode(ReleaseMode.loop)).thenAnswer((_) async {});
    when(() => bgPlayer.setVolume(any())).thenAnswer((_) async {});
    when(() => bgPlayer.play(any())).thenAnswer((_) async {});

    await audioService.playBackgroundMusic();

    verify(() => bgPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
    verify(() => bgPlayer.setVolume(0.5)).called(1);
    verify(() => bgPlayer.play(any())).called(1);
  });

  test('playShootSound respects sound settings', () async {
    when(() => sfxPlayer.setVolume(any())).thenAnswer((_) async {});
    when(() => sfxPlayer.play(any())).thenAnswer((_) async {});

    await audioService.playShootSound();

    verify(() => sfxPlayer.setVolume(1.0)).called(1);
    verify(() => sfxPlayer.play(any())).called(1);
  });
}
