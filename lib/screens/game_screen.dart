import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memory_rampage/utils/colors.dart';
import 'package:memory_rampage/utils/constants.dart';
import 'package:memory_rampage/widgets/game_grid_cell.dart';
import 'package:memory_rampage/widgets/stats_panel.dart';
import 'package:memory_rampage/widgets/game_over_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:memory_rampage/music/background_music_service.dart';
import 'package:memory_rampage/music/sound_effect_service.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  // Game State
  int _currentLevel = 1;
  int _lives = 3;
  int _score = 0;
  int _highScore = 0;

  // tracks whether user earned the reward
  RewardedAd? _rewardedAd;
  bool _isRewarded = false;
  bool _isAdLoading = false;

  // Level Config
  int _gridSize = 3;
  int _cellsToFlashCount = 2;
  Duration _flashDuration = const Duration(milliseconds: 1000);
  int levelFlashTime = 1000;
  int _levelTimeSeconds = 15;

  // Grid and Cell State
  List<CellState> _cellStates = [];
  List<int> _flashedIndices = [];
  List<int> _tappedCorrectIndices = [];
  List<int> _cellNumbers = [];

  // Timers and UI State
  Timer? _levelTimer;
  int _remainingTime = 0;
  bool _isShowingLevelAnnouncement = false;
  bool _isGamePaused = false;
  bool _isUserInputAllowed = false;
  bool _isFlashing = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHighScore();
    _startGame();
  }

  // to stop music when app goes to background or inactive
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      BackgroundMusicService.pauseAndRemember();
    } else if (state == AppLifecycleState.resumed) {
      BackgroundMusicService.resumeIfWasPlaying();
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(prefsHighScoreKey) ?? 0;
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefsHighScoreKey, _highScore);
  }

  void _startGame() {
    _currentLevel = 1;
    _lives = 3;
    _score = 0;
    _isGamePaused = false;
    _setupNewLevel();
  }

  void _setupNewLevel() {
    setState(() {
      _isUserInputAllowed = false;
      _tappedCorrectIndices.clear();
      _flashedIndices.clear();

      // for Difficulty scaling
      _gridSize = 2 + _currentLevel;
      _cellsToFlashCount = (1 + _currentLevel).clamp(2, (_gridSize * _gridSize) ~/ 2); // At least 2, max half
      // _flashDuration = Duration(milliseconds: _currentLevel < 5 ? 400 + (_currentLevel * 100): 1700,);
      if(_currentLevel < 5){
        _flashDuration = Duration(milliseconds: levelFlashTime);
      }else if(_currentLevel == 5){
        _flashDuration = Duration(milliseconds: levelFlashTime*2);
      }else if(_currentLevel == 7){
        _flashDuration = Duration(milliseconds: levelFlashTime*3);
      }else{
        levelFlashTime = 300 + levelFlashTime;
        _flashDuration = Duration(milliseconds: 300 + levelFlashTime);
      }
      
      _levelTimeSeconds = (10 + _gridSize * 2).clamp(10, 60) ;
      _remainingTime = _levelTimeSeconds;

      _cellStates = List.generate(_gridSize * _gridSize, (_) => CellState.initial);

      // add numbers to the cell
      final totalCells = _gridSize * _gridSize;
      _cellNumbers = List.generate(totalCells, (i) => i + 1);
      // if (_currentLevel >= 6) {
        _cellNumbers.shuffle(_random);
      // }

      _isShowingLevelAnnouncement = true;
    });
    Future.delayed(levelAnnouncementDuration, () {
      if (!mounted) return;
      setState(() {
        _isShowingLevelAnnouncement = false;
      });
      _flashCellsSequence();
    });
  }

  void _flashCellsSequence() async {
    if (!mounted) return;
    setState(() {
      _isFlashing = true;
      _flashedIndices = _pickRandomCells();
      for (int index in _flashedIndices) {
        _cellStates[index] = CellState.flashing;
      }
    });

    await Future.delayed(_flashDuration);
    if (!mounted) return;

    setState(() {
      for (int index in _flashedIndices) {
        if (!_tappedCorrectIndices.contains(index)) {
          _cellStates[index] = CellState.initial;
        }
      }
      _isUserInputAllowed = true;
      _isFlashing = false;
    });
    _startLevelTimer();
  }

  List<int> _pickRandomCells() {
    final List<int> availableIndices = List.generate(_gridSize * _gridSize, (i) => i);
    availableIndices.shuffle(_random);
    return availableIndices.sublist(0, _cellsToFlashCount);
  }

  void _startLevelTimer() {
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGamePaused || !_isUserInputAllowed) return;

      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleCellTap(int index) async {
    if (!_isUserInputAllowed || _isGamePaused || _tappedCorrectIndices.contains(index) || _isFlashing) return;

    if (_flashedIndices.contains(index)) {
      setState(() {
        _cellStates[index] = CellState.revealedCorrect;
        _tappedCorrectIndices.add(index);
        _score += 10;
        if (_score > _highScore) _highScore = _score;
      });

      if (_tappedCorrectIndices.length == _flashedIndices.length) {
        _levelTimer?.cancel();
        _score += 20; // Level complete bonus
        if (_score > _highScore) _highScore = _score;
        // Level Complete logic
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _currentLevel++;
          _setupNewLevel();
        });
      }
    } else {
      // Wrong tap

      await BackgroundMusicService.pauseAndRemember();
      await SoundEffectService.playWrongBell();

      setState(() {
        _cellStates[index] = CellState.revealedIncorrect;
        _lives--;
      });

      await Future.delayed(Duration(milliseconds: 800));
      await BackgroundMusicService.resumeIfWasPlaying();

      Future.delayed(flashRevertDelay, () {
        if (!mounted) return;
        if (!_flashedIndices.contains(index)) {
          setState(() => _cellStates[index] = CellState.initial);
        }
      });

      if (_lives <= 0) {
        _gameOver(false);
      }
    }
  }

  void _handleTimeout() {
     if (!_isUserInputAllowed) return;
    _isUserInputAllowed = false;
    _lives--;
    if (_lives <= 0) {
      _gameOver(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Time's up! -1 Life"), duration: Duration(seconds: 1)),
      );
       Future.delayed(const Duration(seconds: 1), () {
         if(!mounted) return;
         _tappedCorrectIndices.clear();
         for(int i=0; i<_cellStates.length; i++) {
           _cellStates[i] = CellState.initial;
         }
         _remainingTime = _levelTimeSeconds;
         _flashCellsSequence();
       });
    }
  }

  void _gameOver(bool byTimeout) {
    _levelTimer?.cancel();
    _isUserInputAllowed = false;
    _saveHighScore();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return GameOverDialog(
          score: _score,
          level: _currentLevel,
          isNewHighScore: _score > 0 && _score == _highScore,
          onRestart: () {
            Navigator.of(dialogContext).pop();
            _startGame();
          },
          onContinue: _lives < 3 ? () { 
            Navigator.of(dialogContext).pop();
            // _continueGame();
            _showRewardedAd();
          } : null,
          onGoHome: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showRewardedAd() {
    setState(() {
      _isAdLoading = true;
    });

    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoading = false;
          });

          _rewardedAd = ad;
          _isRewarded = false;

          _rewardedAd!
            ..fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _rewardedAd = null;
                _isRewarded ? _continueGame() : _goHome();
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
                _rewardedAd = null;
                _goHome();
              },
            )
            ..show(onUserEarnedReward: (ad, reward) {
              _isRewarded = true;
            });
        },
        onAdFailedToLoad: (err) {
          setState(() {
            _isAdLoading = false;
          });

          _rewardedAd = null;
          _goHome();
        },
      ),
    );
  }



  void _goHome() {
    Navigator.of(context).pop();       // pop GameScreen -> HomeScreen
  }
// Logic for continuing by ad
  void _continueGame() { 
    setState(() {
      _lives = (_lives + 2).clamp(1,3);
      _score = (_score * 0.9).round();
      _isGamePaused = false;
      _tappedCorrectIndices.clear();
      for(int i=0; i<_cellStates.length; i++) {
         _cellStates[i] = CellState.initial;
      }
      _remainingTime = _levelTimeSeconds;
    });
    _flashCellsSequence();
  }


  void _togglePause() {
    setState(() {
      _isGamePaused = !_isGamePaused;
      if (_isGamePaused) {
        _levelTimer?.cancel(); // Pause timer logic if needed
      } else {
        _startLevelTimer(); // Resume timer
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _levelTimer?.cancel();
    BackgroundMusicService.stopMusic();
    super.dispose();
  }

  Widget _buildGameGrid() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _gridSize * _gridSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
          ),
          itemBuilder: (context, index) {
            return GameGridCell(
              cellState: _cellStates[index],
              isClickable: _isUserInputAllowed && !_isGamePaused,
              onTap: () => _handleCellTap(index),
              number: _cellNumbers[index],
              // number: _currentLevel >= 6 ? _cellNumbers[index] : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelAnnouncement() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            child: Text(
              'Level $_currentLevel',
              style: const TextStyle(fontSize: 34, color: gamePrimaryPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  onPressed: _togglePause,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                  onPressed: () {
                    _togglePause(); // Unpause before leaving
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(BackgroundMusicService.isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(BackgroundMusicService.isPlaying ? 'Pause Sounds' : 'Resume Sounds'),
                  onPressed: (){
                    setState(() {
                      if (BackgroundMusicService.isPlaying) {
                        BackgroundMusicService.pauseMusic();
                        SoundEffectService.pauseBellSound();
                      } else {
                        BackgroundMusicService.resumeMusic();
                        SoundEffectService.resumeBellSound();
                      }
                      
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String formattedTime = '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                StatsPanel(
                  level: _currentLevel,
                  time: _isShowingLevelAnnouncement ? '--:--' : formattedTime,
                  lives: _lives,
                  score: _score,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildGameGrid(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.menu),
                          label: Text('Options'),
                          onPressed: _isShowingLevelAnnouncement || !_isUserInputAllowed && !_isFlashing && _lives > 0 ? null : _togglePause, // to disable pause during announcement or if game not active
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.home),
                          label: const Text('Home'),
                          onPressed: () {
                            if(_isGamePaused) _togglePause(); // Unpause before leaving
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isShowingLevelAnnouncement) _buildLevelAnnouncement(),
            if (_isGamePaused) _buildPauseOverlay(),

            // 👇 NEW: Ad Loading Overlay
            if (_isAdLoading)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Just a moment…',
                        style: TextStyle(color: Colors.white),
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