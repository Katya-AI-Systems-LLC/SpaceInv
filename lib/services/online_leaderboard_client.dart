import 'leaderboard_service.dart';

/// Abstraction for an online leaderboard backend.
///
/// Implement this interface and pass an instance to
/// `LeaderboardService().configureOnlineClient(...)` to enable
/// synchronization with a remote leaderboard.
///
/// Example implementation ideas (НЕ реализовано здесь):
/// - Firebase / Firestore collection
/// - Custom REST API
/// - Supabase / PocketBase и т.п.
abstract class OnlineLeaderboardClient {
  /// Fetches leaderboard entries from a remote backend.
  /// Should return scores sorted by descending score.
  Future<List<LeaderboardEntry>> fetchEntries();

  /// Submits a new score entry to the remote backend.
  Future<void> submitEntry(LeaderboardEntry entry);
}
