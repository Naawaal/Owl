// language: Dart, file: test/core/utils/haptic_helper_test.dart, target: Flutter / Owl MOBA HUD

import 'package:flutter_test/flutter_test.dart';
import 'package:owl_core/owl_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticHelper', () {
    test('does not throw when triggering tactical haptics', () async {
      await expectLater(HapticHelper.lightImpact(), completes);
      await expectLater(HapticHelper.mediumImpact(), completes);
      await expectLater(HapticHelper.heavyImpact(), completes);
      await expectLater(HapticHelper.vibrate(), completes);
      await expectLater(HapticHelper.selectionClick(), completes);
    });

    test('tactical alert methods complete successfully', () async {
      await expectLater(HapticHelper.alert30s(), completes);
      await expectLater(HapticHelper.warning10s(), completes);
      await expectLater(HapticHelper.spawnAlert(), completes);
    });

    test('respects enabled=false flag without error', () async {
      await expectLater(HapticHelper.triggerAlert(TacticalHapticType.warning30s, enabled: false), completes);
      await expectLater(HapticHelper.triggerAlert(TacticalHapticType.critical10s, enabled: false), completes);
      await expectLater(HapticHelper.triggerAlert(TacticalHapticType.spawn, enabled: false), completes);
      await expectLater(HapticHelper.triggerAlert(TacticalHapticType.tap, enabled: false), completes);
    });
  });
}
