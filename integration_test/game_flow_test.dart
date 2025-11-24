import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:space_invaders/main.dart';
import 'package:space_invaders/widgets/bullet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Start game and fire bullet', (tester) async {
    await tester.pumpWidget(const SpaceInvadersApp());
    await tester.pumpAndSettle();

    expect(find.text('SPACE INVADERS'), findsOneWidget);
    await tester.tap(find.text('START GAME'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Score:'), findsOneWidget);

    // Tap anywhere on the game canvas to fire a bullet
    final gestureDetector = find.byType(GestureDetector).first;
    await tester.tap(gestureDetector);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(BulletWidget), findsWidgets);
  });
}
