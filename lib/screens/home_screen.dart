import 'package:flutter/material.dart';
import 'package:memory_rampage/screens/game_screen.dart';
import 'package:memory_rampage/utils/colors.dart';
import 'package:memory_rampage/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_rampage/music/background_music_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _highScore = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt(prefsHighScoreKey) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Memory\nRampage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: gameTitlePurple,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_highScore > 0)
                    Text(
                      'High Score: $_highScore',
                      style: const TextStyle(
                        fontSize: 16,
                        color: gameTextSecondary,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Memorize, Tap & Conquer!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: gameTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      await BackgroundMusicService.playMusic();
                      Navigator.pop(context); // Dismiss loader

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      ).then((_) => _loadHighScore());
                    },
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}