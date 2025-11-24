import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';
import 'online_leaderboard_client.dart';

class LeaderboardEntry {
  final int score;
  final int level;
  final GameMode mode;
  final DateTime date;

  LeaderboardEntry({
    required this.score,
    required this.level,
    required this.mode,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'level': level,
        'mode': mode.toString(),
        'date': date.toIso8601String(),
      };

  static LeaderboardEntry fromJson(Map<String, dynamic> json) {
    final modeString = (json['mode'] as String?) ?? GameMode.classic.toString();
    final mode = GameMode.values.firstWhere(
      (m) => m.toString() == modeString,
      orElse: () => GameMode.classic,
    );
    return LeaderboardEntry(
      score: json['score'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      mode: mode,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  static const String _key = 'leaderboard_entries_v1';
  static const int _maxEntries = 10;

  OnlineLeaderboardClient? _onlineClient;

  /// Configure an online client to enable syncing scores with a backend.
  void configureOnlineClient(OnlineLeaderboardClient client) {
    _onlineClient = client;
  }

  Future<List<LeaderboardEntry>> _loadLocalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardEntry.fromJson)
        .toList();
  }

  Future<void> _saveLocalEntries(List<LeaderboardEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<List<LeaderboardEntry>> getEntries() async {
    try {
      // Always load local entries
      final local = await _loadLocalEntries();
      final combined = <LeaderboardEntry>[]..addAll(local);

      // Optionally merge remote entries
      if (_onlineClient != null) {
        try {
          final remote = await _onlineClient!.fetchEntries();
          combined.addAll(remote);
        } catch (_) {
          // If remote fetch fails, fall back to local only
        }
      }

      combined.sort((a, b) => b.score.compareTo(a.score));
      return combined.take(_maxEntries).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addEntry({
    required int score,
    required int level,
    required GameMode mode,
  }) async {
    if (score <= 0) return;
    try {
      final current = await _loadLocalEntries();
      final entry = LeaderboardEntry(
        score: score,
        level: level,
        mode: mode,
        date: DateTime.now(),
      );

      current.add(entry);
      current.sort((a, b) => b.score.compareTo(a.score));
      final trimmed = current.take(_maxEntries).toList();
      await _saveLocalEntries(trimmed);

      // Optionally submit to online backend
      if (_onlineClient != null) {
        try {
          await _onlineClient!.submitEntry(entry);
        } catch (_) {
          // Ignore remote submit failure, keep local result
        }
      }
    } catch (e) {
      // ignore
    }
  }
}
