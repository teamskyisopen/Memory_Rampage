import 'dart:math';
import 'package:just_audio/just_audio.dart';

class BackgroundMusicService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;
  static bool _isPlaying = false;
  static bool _wasPlayingBeforePause = false;
  

  static final List<String> _tracks = [
    'assets/sound/bg_1.mp3',
    'assets/sound/bg_2.mp3',
    'assets/sound/bg_3.mp3',
  ];

  static Future<void> loadMusic() async {
    if (_isInitialized) return;

    final random = Random();
    final shuffledTracks = [..._tracks]..shuffle(random);

    final playlist = ConcatenatingAudioSource(
      children: shuffledTracks.map((track) => AudioSource.asset(track)).toList(),
    );

    await _player.setAudioSource(playlist);
    await _player.setLoopMode(LoopMode.all);
    _isInitialized = true;
  }

  static Future<void> playMusic() async {
    if (!_isInitialized) await loadMusic();
    _player.play();
    
    _isPlaying = true;
  }

  static Future<void> pauseMusic() async {
    _player.pause();
    _isPlaying = false;
  }

  static Future<void> resumeMusic() async {
    _player.play();
    _isPlaying = true;
  }

  static Future<void> stopMusic() async {
    _player.stop();
    _isPlaying = false;
  }

  static Future<void> pauseAndRemember() async {
    _wasPlayingBeforePause = _isPlaying;
    if (_isPlaying) {
      pauseMusic();
    }
  }

  static Future<void> resumeIfWasPlaying() async {
    if (_wasPlayingBeforePause) {
      resumeMusic();
      _wasPlayingBeforePause = false;
    }
  }

  static bool get isPlaying => _isPlaying;
}
