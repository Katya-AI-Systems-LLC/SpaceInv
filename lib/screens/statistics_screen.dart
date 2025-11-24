import 'package:flutter/material.dart';
import '../services/statistics_service.dart';
import '../services/localization_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await _statisticsService.getStatistics();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _resetStatistics() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'Are you sure you want to reset all statistics? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _statisticsService.resetStatistics();
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.t('title_statistics')),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _resetStatistics,
            tooltip: 'Reset Statistics',
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStatCard(
              icon: Icons.play_arrow,
              title: 'Games Played',
              value: '${_stats['games_played'] ?? 0}',
              color: Colors.blue,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.star,
              title: 'High Score',
              value: '${_stats['high_score'] ?? 0}',
              color: Colors.amber,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.trending_up,
              title: 'Total Score',
              value: '${_stats['total_score'] ?? 0}',
              color: Colors.green,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.flag,
              title: 'Highest Level',
              value: '${_stats['highest_level'] ?? 0}',
              color: Colors.purple,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.bug_report,
              title: 'Enemies Killed',
              value: '${_stats['total_enemies_killed'] ?? 0}',
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            _buildStatCard(
              icon: Icons.emoji_events,
              title: 'Games Won',
              value: '${_stats['games_won'] ?? 0}',
              color: Colors.orange,
            ),
            const SizedBox(height: 30),
            
            // Win rate calculation
            if ((_stats['games_played'] ?? 0) > 0) ...[
              Card(
                color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Win Rate',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${((_stats['games_won'] ?? 0) / (_stats['games_played'] ?? 1) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

