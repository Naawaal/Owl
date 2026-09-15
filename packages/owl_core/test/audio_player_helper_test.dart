// language: Dart, file: test/core/utils/audio_player_helper_test.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';

class MockAudioCuePlayer implements AudioCuePlayer {
  final List<CueSound> playedCues = [];
  bool wasStopped = false;
  bool wasDisposed = false;

  @override
  Future<void> playCue(CueSound cue, {bool enabled = true}) async {
    if (enabled) {
      playedCues.add(cue);
    }
  }

  @override
  Future<void> stop() async {
    wasStopped = true;
  }

  @override
  void dispose() {
    wasDisposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerHelper', () {
    late MockAudioCuePlayer mockPlayer;

    setUp(() {
      mockPlayer = MockAudioCuePlayer();
      AudioPlayerHelper.setPlayer(mockPlayer);
    });

    test('plays tactical sound cues through injected player', () async {
      await AudioPlayerHelper.play30sAlert();
      await AudioPlayerHelper.play10sWarning();
      await AudioPlayerHelper.playSpawn();
      await AudioPlayerHelper.playClick();

      expect(
        mockPlayer.playedCues,
        equals([
          CueSound.alert30s,
          CueSound.warning10s,
          CueSound.spawn,
          CueSound.click,
        ]),
      );
    });

    test('respects enabled=false flag', () async {
      await AudioPlayerHelper.play30sAlert(enabled: false);
      await AudioPlayerHelper.play10sWarning(enabled: false);
      await AudioPlayerHelper.playSpawn(enabled: false);

      expect(mockPlayer.playedCues, isEmpty);
    });

    test('delegates stop command to player', () async {
      await AudioPlayerHelper.stop();
      expect(mockPlayer.wasStopped, isTrue);
    });
  });
}
