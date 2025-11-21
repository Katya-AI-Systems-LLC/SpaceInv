import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 1.0;
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = _audioService.soundEnabled;
      _musicEnabled = _audioService.musicEnabled;
      _soundVolume = _audioService.soundVolume;
      _musicVolume = _audioService.musicVolume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
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
            // Sound Settings Section
            Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audio Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sound Effects Toggle
                    SwitchListTile(
                      title: const Text(
                        'Sound Effects',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Enable game sound effects',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                          _audioService.setSoundEnabled(value);
                        });
                      },
                      activeThumbColor: Colors.green,
                    ),
                    
                    // Sound Volume
                    if (_soundEnabled) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Sound Volume: ${(_soundVolume * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: _soundVolume,
                        onChanged: (value) {
                          setState(() {
                            _soundVolume = value;
                            _audioService.setSoundVolume(value);
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                    
                    const Divider(color: Colors.white24),
                    
                    // Music Toggle
                    SwitchListTile(
                      title: const Text(
                        'Background Music',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Enable background music',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _musicEnabled,
                      onChanged: (value) {
                        setState(() {
                          _musicEnabled = value;
                          _audioService.setMusicEnabled(value);
                        });
                      },
                      activeThumbColor: Colors.green,
                    ),
                    
                    // Music Volume
                    if (_musicEnabled) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Music Volume: ${(_musicVolume * 100).toInt()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Slider(
                        value: _musicVolume,
                        onChanged: (value) {
                          setState(() {
                            _musicVolume = value;
                            _audioService.setMusicVolume(value);
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Game Info Section
            Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Space Invaders',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A classic arcade game reimagined with Flutter.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

