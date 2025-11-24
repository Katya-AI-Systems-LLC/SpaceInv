import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_mode.dart';
import 'leaderboard_service.dart';
import 'online_leaderboard_client.dart';

/// Base URL for the online leaderboard backend.
///
/// Configure via:
///   --dart-define=LEADERBOARD_API_BASE_URL=https://your.api
///
/// Backend is expected to expose:
///   GET  /leaderboard
///   POST /leaderboard
/// with JSON bodies compatible with [LeaderboardEntry.toJson].
const String kLeaderboardApiBaseUrl =
    String.fromEnvironment('LEADERBOARD_API_BASE_URL', defaultValue: '');

/// Optional API key header value.
/// Configure via:
///   --dart-define=LEADERBOARD_API_KEY=your_key
const String kLeaderboardApiKey =
    String.fromEnvironment('LEADERBOARD_API_KEY', defaultValue: '');

class RestOnlineLeaderboardClient implements OnlineLeaderboardClient {
  final http.Client _client;

  const RestOnlineLeaderboardClient({http.Client? client})
      : _client = client ?? const http.Client();

  bool get _enabled => kLeaderboardApiBaseUrl.isNotEmpty;

  Uri _buildUri(String path) {
    final base = kLeaderboardApiBaseUrl.endsWith('/')
        ? kLeaderboardApiBaseUrl.substring(0, kLeaderboardApiBaseUrl.length - 1)
        : kLeaderboardApiBaseUrl;
    return Uri.parse('$base$path');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (kLeaderboardApiKey.isNotEmpty) {
      headers['x-api-key'] = kLeaderboardApiKey;
    }
    return headers;
  }

  @override
  Future<List<LeaderboardEntry>> fetchEntries() async {
    if (!_enabled) return [];
    try {
      final uri = _buildUri('/leaderboard');
      final response = await _client.get(uri, headers: _headers());
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return [];
      }
      final body = response.body;
      if (body.isEmpty) return [];
      final decoded = json.decode(body);
      final List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['entries'] is List) {
        list = decoded['entries'] as List<dynamic>;
      } else {
        return [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntry.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> submitEntry(LeaderboardEntry entry) async {
    if (!_enabled) return;
    try {
      final uri = _buildUri('/leaderboard');
      await _client.post(
        uri,
        headers: _headers(),
        body: json.encode(entry.toJson()),
      );
    } catch (_) {
      // Ignore network errors; local leaderboard will still work.
    }
  }
}
