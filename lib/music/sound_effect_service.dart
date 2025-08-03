import 'package:audioplayers/audioplayers.dart';

class SoundEffectService {
  static final AudioPlayer _effectPlayer = AudioPlayer();
  static bool _canPlay = true;

  static Future<void> playWrongBell() async {
    if (!_canPlay) return;
    await _effectPlayer.play(AssetSource('sound/wrong-bell-sound.mp3'));
  }

  static Future<void> pauseBellSound() async {
    _canPlay = false;
  }

  static Future<void> resumeBellSound() async {
    _canPlay = true;
  }
}
