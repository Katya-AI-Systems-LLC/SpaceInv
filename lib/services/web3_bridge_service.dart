import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models/game_mode.dart';

/// Base URL for optional web3 / blockchain bridge backend.
///
/// Configure via:
///   --dart-define=WEB3_BRIDGE_API_BASE_URL=https://your-web3-bridge
const String kWeb3BridgeApiBaseUrl =
    String.fromEnvironment('WEB3_BRIDGE_API_BASE_URL', defaultValue: '');

/// Optional API key for the web3 bridge backend.
///
/// Configure via:
///   --dart-define=WEB3_BRIDGE_API_KEY=your_key
const String kWeb3BridgeApiKey =
    String.fromEnvironment('WEB3_BRIDGE_API_KEY', defaultValue: '');

/// A small, optional helper that can send game result "proofs" to an
/// external web3 / blockchain bridge backend.
///
/// If [kWeb3BridgeApiBaseUrl] is empty, all methods are no-ops.
class Web3BridgeService {
  static final Web3BridgeService _instance = Web3BridgeService._internal();
  factory Web3BridgeService() => _instance;
  Web3BridgeService._internal();

  final http.Client _client = const http.Client();
  final math.Random _random = math.Random();

  bool get isEnabled => kWeb3BridgeApiBaseUrl.isNotEmpty;

  Uri _buildUri(String path) {
    final base = kWeb3BridgeApiBaseUrl.endsWith('/')
        ? kWeb3BridgeApiBaseUrl.substring(0, kWeb3BridgeApiBaseUrl.length - 1)
        : kWeb3BridgeApiBaseUrl;
    return Uri.parse('$base$path');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (kWeb3BridgeApiKey.isNotEmpty) {
      headers['x-api-key'] = kWeb3BridgeApiKey;
    }
    return headers;
  }

  /// Sends a generic game result proof to the bridge backend.
  ///
  /// The backend is free to map this payload to any target chain or format.
  Future<void> sendGameResultProof({
    required int score,
    required int level,
    required int enemiesKilled,
    required bool won,
    required GameMode mode,
  }) async {
    if (!isEnabled) return;
    try {
      final uri = _buildUri('/web3/proofs/game-result');
      final now = DateTime.now().toUtc();
      final runId = 'run_${now.microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}';
      final payload = {
        'score': score,
        'level': level,
        'enemiesKilled': enemiesKilled,
        'won': won,
        'mode': mode.toString(),
        'timestamp': now.toIso8601String(),
      };
      final body = json.encode({
        'type': 'game_result',
        'version': 1,
        'game': 'space_invaders',
        'runId': runId,
        'payload': payload,
      });
      await _client.post(uri, headers: _headers(), body: body);
    } catch (_) {
      // Intentionally ignore network/bridge errors; core game must remain stable.
    }
  }
}
