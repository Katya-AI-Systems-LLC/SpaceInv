import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_invaders/services/statistics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = StatisticsService();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('recordGame stores cumulative stats', () async {
    await service.recordGame(
      score: 100,
      level: 3,
      enemiesKilled: 5,
      won: true,
    );

    final stats = await service.getStatistics();
    expect(stats['games_played'], 1);
    expect(stats['total_score'], 100);
    expect(stats['highest_level'], 3);
    expect(stats['total_enemies_killed'], 5);
    expect(stats['games_won'], 1);
  });

  test('recordGame updates high score', () async {
    await service.recordGame(
      score: 200,
      level: 2,
      enemiesKilled: 2,
      won: false,
    );

    final stats = await service.getStatistics();
    expect(stats['high_score'], 200);
  });

  test('resetStatistics clears accumulated values', () async {
    await service.recordGame(
      score: 50,
      level: 1,
      enemiesKilled: 1,
      won: false,
    );

    await service.resetStatistics();
    final stats = await service.getStatistics();
    expect(stats['games_played'], 0);
    expect(stats['total_score'], 0);
    expect(stats['highest_level'], 0);
    expect(stats['total_enemies_killed'], 0);
    expect(stats['games_won'], 0);
  });
}
