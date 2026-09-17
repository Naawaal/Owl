// language: Dart, file: tts_announcer.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reactive provider for the tactical voice announcer.
final ttsAnnouncerProvider = Provider<TtsAnnouncer>((ref) => TtsAnnouncer());

/// Speaks Guardian tactical callouts through on-device TTS.
///
/// Configured once to mix with game audio and never duck it (iOS mix
/// category, Android no-focus playback). Every platform call is guarded:
/// missing plugins or engines resolve to `false`, never throw — safe in
/// tests and on devices without TTS.
class TtsAnnouncer {
  FlutterTts? _tts;
  bool _configured = false;
  DateTime? _lastSpokeAt;

  /// Test seam: replaces platform speech when provided.
  final Future<dynamic> Function(String text)? speakDelegate;

  TtsAnnouncer({this.speakDelegate});

  /// Timestamp of the last attempted announcement, if any.
  DateTime? get lastSpokeAt => _lastSpokeAt;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      _tts ??= FlutterTts();
      await _tts!.setLanguage('en-US');
      await _tts!.setSpeechRate(0.55);
      await _tts!.setVolume(1.0);
      await _tts!.setPitch(1.0);
      await _tts!.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
      _configured = true;
    } catch (_) {}
  }

  /// Speaks [text]. Returns true when playback started.
  /// `focus: false` keeps game audio playing underneath on Android.
  Future<bool> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    _lastSpokeAt = DateTime.now();
    try {
      if (speakDelegate != null) {
        await speakDelegate!(trimmed);
        return true;
      }
      await _ensureConfigured();
      final engine = _tts;
      if (engine == null) return false;
      await engine.speak(trimmed, focus: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stops any in-progress announcement. Never throws.
  Future<void> stop() async {
    try {
      if (speakDelegate == null) {
        await _tts?.stop();
      }
    } catch (_) {}
  }
}
