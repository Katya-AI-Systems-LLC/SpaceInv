import 'package:flutter/material.dart';

import '../models/upgrade_type.dart';
import '../services/currency_service.dart';
import '../services/upgrades_service.dart';
import '../services/localization_service.dart';

class HangarScreen extends StatefulWidget {
  const HangarScreen({super.key});

  @override
  State<HangarScreen> createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final UpgradesService _upgradesService = UpgradesService();

  int _credits = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final credits = await _currencyService.getCredits();
    if (!mounted) return;
    setState(() {
      _credits = credits;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.t('title_hangar')),
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.t('lbl_credits'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.currency_exchange,
                            color: Colors.amberAccent),
                        const SizedBox(width: 8),
                        Text(
                          '$_credits',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...UpgradeType.values.map((type) => _buildUpgradeCard(loc, type)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(LocalizationService loc, UpgradeType type) {
    final level = _upgradesService.getLevel(type);
    final max = _upgradesService.getMaxLevel(type);
    final bool atMax = level >= max;
    final price = atMax ? null : _upgradesService.getNextLevelPrice(type);

    final nameKey = 'upgrade_${type.name}_name';
    final descKey = 'upgrade_${type.name}_desc';

    return Card(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.t(nameKey),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lv $level / $max',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              loc.t(descKey),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!atMax)
                  Text(
                    '${loc.t('lbl_price')}: ${price ?? 0}',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 14,
                    ),
                  )
                else
                  Text(
                    loc.t('upgrade_max_level'),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),
                ElevatedButton(
                  onPressed: atMax ? null : () => _onUpgradePressed(type),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        atMax ? Colors.grey : Colors.greenAccent.shade700,
                  ),
                  child: Text(
                    atMax ? loc.t('btn_maxed') : loc.t('btn_upgrade'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onUpgradePressed(UpgradeType type) async {
    final loc = LocalizationService();
    final ok = await _upgradesService.upgrade(type);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('upgrade_not_enough_credits')),
        ),
      );
      return;
    }
    await _load();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.t('upgrade_purchased')),
      ),
    );
  }
}
