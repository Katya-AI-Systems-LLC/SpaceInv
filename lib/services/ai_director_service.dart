import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_mode.dart';

const String kAiDirectorApiBaseUrl =
    String.fromEnvironment('AI_DIRECTOR_API_BASE_URL', defaultValue: '');

const String kAiDirectorApiKey =
    String.fromEnvironment('AI_DIRECTOR_API_KEY', defaultValue: '');

class AiDirectorService {
  static final AiDirectorService _instance = AiDirectorService._internal();
  factory AiDirectorService() => _instance;
  AiDirectorService._internal();

  final http.Client _client = const http.Client();

  bool get isEnabled => kAiDirectorApiBaseUrl.isNotEmpty;

  Uri _buildUri(String path) {
    final base = kAiDirectorApiBaseUrl.endsWith('/')
        ? kAiDirectorApiBaseUrl.substring(0, kAiDirectorApiBaseUrl.length - 1)
        : kAiDirectorApiBaseUrl;
    return Uri.parse('$base$path');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (kAiDirectorApiKey.isNotEmpty) {
      headers['x-api-key'] = kAiDirectorApiKey;
    }
    return headers;
  }

  Future<void> sendGameSummary({
    required int score,
    required int level,
    required int enemiesKilled,
    required bool won,
    required GameMode mode,
  }) async {
    if (!isEnabled) return;
    try {
      final uri = _buildUri('/ai/director/game-summary');
      final body = json.encode({
        'score': score,
        'level': level,
        'enemiesKilled': enemiesKilled,
        'won': won,
        'mode': mode.toString(),
      });
      await _client.post(uri, headers: _headers(), body: body);
    } catch (_) {}
  }
}
