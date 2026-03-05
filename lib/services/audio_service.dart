import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class AmbientAudioService with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();
  String? _currentAsset;
  bool _isPlaying = false;
  double _volume = 0.5;

  AmbientAudioService() {
    // Listen to App Lifecycle events (Background/Foreground)
    WidgetsBinding.instance.addObserver(this);
  }

  bool get isPlaying => _isPlaying;
  String? get currentAsset => _currentAsset;
  double get volume => _volume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the app goes into the background, stop the audio automatically
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.hidden) {
      if (_isPlaying) {
        stop();
      }
    }
  }

  Future<void> play(String assetPath) async {
    if (_currentAsset == assetPath && _isPlaying) {
        return;
    }

    try {
      if (_isPlaying) {
          await _player.stop();
      }

      _currentAsset = assetPath;
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one); 
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
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
  }
}
