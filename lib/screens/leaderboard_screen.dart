import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../services/leaderboard_service.dart';
import '../services/localization_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<LeaderboardEntry> _entries = [];
  bool _showBossRushOnly = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final items = await _leaderboardService.getEntries();
    setState(() {
      _entries = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    final filtered = _showBossRushOnly
        ? _entries.where((e) => e.mode == GameMode.bossRush).toList()
        : _entries;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.t('title_leaderboard')),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntries,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.indigo.shade900],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text(loc.t('leaderboard_tab_all')),
                    selected: !_showBossRushOnly,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _showBossRushOnly = false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(loc.t('leaderboard_tab_boss_rush')),
                    selected: _showBossRushOnly,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(() {
                        _showBossRushOnly = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        loc.t('leaderboard_empty'),
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final pos = index + 1;
                        final modeLabel = e.mode.label;
                        return Card(
                          color: Colors.black54,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: pos == 1
                                  ? Colors.amber
                                  : pos == 2
                                      ? Colors.grey
                                      : pos == 3
                                          ? Colors.brown
                                          : Colors.blueGrey,
                              child: Text(
                                '$pos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'Score: ${e.score}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Level: ${e.level} • Mode: $modeLabel',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
