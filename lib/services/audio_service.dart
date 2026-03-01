import 'package:just_audio/just_audio.dart';

class AmbientAudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentAsset;
  bool _isPlaying = false;
  double _volume = 0.5;

  bool get isPlaying => _isPlaying;
  String? get currentAsset => _currentAsset;
  double get volume => _volume;

  Future<void> play(String assetPath) async {
    // If same track is already playing, do nothing (idempotent)
    if (_currentAsset == assetPath && _isPlaying) {
        return;
    }

    try {
      // If switching tracks, stop the current one first cleanly
      if (_isPlaying) {
          await _player.stop();
      }

      _currentAsset = assetPath;
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one); // Infinite loop
      await _player.setVolume(_volume);
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      print("Error playing audio: $e");
      _isPlaying = false;
      _currentAsset = null;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentAsset = null;
  }
  
  Future<void> setVolume(double value) async {
      _volume = value;
      await _player.setVolume(value);
  }

  void dispose() {
    _player.dispose();
  }
}
