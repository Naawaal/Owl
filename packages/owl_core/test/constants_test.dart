// language: Dart, file: test/core/constants/constants_test.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';

void main() {
  group('AppConstants', () {
    test('verifies metadata and overlay dimensions', () {
      expect(AppConstants.appTitle, equals('Owl'));
      expect(AppConstants.pillWidth, equals(148.0));
      expect(AppConstants.pillHeight, equals(46.0));
      expect(AppConstants.defaultOverlayOpacity, equals(0.92));
      expect(AppConstants.defaultOverlayScale, equals(1.00));
    });

    test('verifies supported game profiles', () {
      expect(AppConstants.defaultSupportedGames, contains('Wild Rift'));
      expect(AppConstants.defaultSupportedGames, contains('Mobile Legends'));
      expect(AppConstants.defaultSupportedGames, contains('Pokémon UNITE'));
      expect(AppConstants.defaultSupportedGames.length, equals(3));
    });

    test('verifies tactical threshold seconds', () {
      expect(AppConstants.warningAlertThresholdSeconds, equals(30));
      expect(AppConstants.criticalAlertThresholdSeconds, equals(10));
      expect(AppConstants.immediateSpawnThresholdSeconds, equals(0));
    });
  });

  group('ChannelConstants', () {
    test('verifies platform channel names', () {
      expect(ChannelConstants.overlayChannel, equals('owl/overlay_channel'));
      expect(ChannelConstants.overlayEvents, equals('owl/overlay_events'));
      expect(ChannelConstants.screenProjection, equals('owl/screen_projection'));
    });

    test('verifies channel method and event names', () {
      expect(ChannelConstants.methodShowOverlay, equals('showOverlay'));
      expect(ChannelConstants.methodHideOverlay, equals('hideOverlay'));
      expect(ChannelConstants.eventOverlayClicked, equals('overlay_clicked'));
    });
  });
}
