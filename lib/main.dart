import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';
import 'services/localization_service.dart';
import 'services/leaderboard_service.dart';
import 'services/rest_online_leaderboard_client.dart';
import 'services/upgrades_service.dart';
import 'screens/start_menu_screen.dart';
import 'utils/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Initialize audio service
  await AudioService().initialize();
  await LocalizationService().load();
  await UpgradesService().load();
  // Configure optional online leaderboard client (no-op if base URL is empty)
  LeaderboardService().configureOnlineClient(RestOnlineLeaderboardClient());
  runApp(const SpaceInvadersApp());
}

class SpaceInvadersApp extends StatelessWidget {
  const SpaceInvadersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Invaders',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          // Initialize responsive helper at app level
          ResponsiveHelper().initialize(context);
          return const StartMenuScreen();
        },
      ),
    );
  }
}
