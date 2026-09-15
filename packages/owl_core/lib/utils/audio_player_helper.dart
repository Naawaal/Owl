// language: Dart, file: lib/core/utils/audio_player_helper.dart, target: Flutter / Owl MOBA HUD

import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Distinct tactical audio cue types for game countdowns and overlay actions.
enum CueSound {
  /// Triggered at 30 seconds before objective spawn.
  alert30s('alert_30s.mp3'),

  /// Urgent warning at 10 seconds before objective spawn.
  warning10s('warning_10s.mp3'),

  /// Objective spawned / active on map.
  spawn('spawn.mp3'),

  /// Quick tactile interface click.
  click('click.mp3');

  final String assetFileName;
  const CueSound(this.assetFileName);
}

/// Abstract contract for playing tactical audio cues.
/// Enables swapping between platform system sounds and low-latency audio engines.
abstract class AudioCuePlayer {
  Future<void> playCue(CueSound cue, {bool enabled = true});
  Future<void> stop();
  void dispose();
}

/// Default system audio cue player using Flutter's built-in [SystemSound] service.
/// Provides zero-dependency platform sound fallback.
class SystemAudioCuePlayer implements AudioCuePlayer {
  @override
  Future<void> playCue(CueSound cue, {bool enabled = true}) async {
    if (!enabled) return;

    try {
      switch (cue) {
        case CueSound.alert30s:
          await SystemSound.play(SystemSoundType.click);
          break;
        case CueSound.warning10s:
        case CueSound.spawn:
          await SystemSound.play(SystemSoundType.alert);
          break;
        case CueSound.click:
          await SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (e) {
      developer.log('Failed to play system sound cue: $e', name: 'Owl.Audio');
    }
  }

  @override
  Future<void> stop() async {
    // No-op for brief one-shot system sounds
  }

  @override
  void dispose() {
    // No resources to release
  }
}

/// Provider for the active [AudioCuePlayer] implementation.
final audioCuePlayerProvider = Provider<AudioCuePlayer>((ref) {
  final player = SystemAudioCuePlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

/// High-level static helper providing ergonomic access to tactical cue playback.
class AudioPlayerHelper {
  AudioPlayerHelper._();

  static AudioCuePlayer _instance = SystemAudioCuePlayer();

  /// Configure or inject a custom audio cue player (e.g. Asset-based or native soundpool).
  static void setPlayer(AudioCuePlayer player) {
    _instance = player;
  }

  /// Play the specified [CueSound].
  static Future<void> playCue(CueSound cue, {bool enabled = true}) async {
    if (!enabled) return;
    await _instance.playCue(cue, enabled: enabled);
  }

  /// Tactical 30-second warning sound.
  static Future<void> play30sAlert({bool enabled = true}) async {
    await playCue(CueSound.alert30s, enabled: enabled);
  }

  /// Urgent 10-second warning sound.
  static Future<void> play10sWarning({bool enabled = true}) async {
    await playCue(CueSound.warning10s, enabled: enabled);
  }

  /// Immediate objective spawn sound.
  static Future<void> playSpawn({bool enabled = true}) async {
    await playCue(CueSound.spawn, enabled: enabled);
  }

  /// UI action click sound.
  static Future<void> playClick({bool enabled = true}) async {
    await playCue(CueSound.click, enabled: enabled);
  }

  /// Stops any currently playing loop or long audio.
  static Future<void> stop() async {
    await _instance.stop();
  }
}
