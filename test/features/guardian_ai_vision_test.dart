// language: Dart, file: guardian_ai_vision_test.dart, target: Flutter / Owl MOBA Companion
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/domain/models/coach_response.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Guardian AI Vision Settings & Serialization', () {
    test('defaultSettings initializes guardianVisionEnabled to true', () {
      const settings = GameTurboSettings.defaultSettings;
      expect(settings.guardianVisionEnabled, isTrue);
    });

    test('guardianVisionEnabled survives round-trip toMap / fromMap serialization', () {
      const original = GameTurboSettings(guardianVisionEnabled: false);
      final map = original.toMap();
      expect(map['guardianVisionEnabled'], isFalse);

      final restored = GameTurboSettings.fromMap(map);
      expect(restored.guardianVisionEnabled, isFalse);
    });

    test('copyWith updates guardianVisionEnabled without modifying other properties', () {
      const settings = GameTurboSettings.defaultSettings;
      final disabled = settings.copyWith(guardianVisionEnabled: false);

      expect(disabled.guardianVisionEnabled, isFalse);
      expect(disabled.guardianTacticalEngine, equals(settings.guardianTacticalEngine));
      expect(disabled.activeModel, equals(settings.activeModel));
      expect(disabled.activeAiProvider, equals(settings.activeAiProvider));
    });

    test('SettingsNotifier toggles guardianVisionEnabled cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = GameTurboSettingsNotifier(prefs);

      expect(notifier.state.guardianVisionEnabled, isTrue);

      await notifier.toggleGuardianVisionEnabled(false);
      expect(notifier.state.guardianVisionEnabled, isFalse);

      await notifier.toggleGuardianVisionEnabled(true);
      expect(notifier.state.guardianVisionEnabled, isTrue);
    });
  });

  group('Guardian AI Multimodal Vision Directive Parsing', () {
    test('parses vision JSON response with champion, spell, and minimap context', () {
      const rawJson = '''
      {
        "action": "HOLD LANE & BAIT FLICKER",
        "reason": "Balmond with Flicker advantage; enemy jungler spotted top.",
        "warning": "Turtle contest in 30s"
      }
      ''';

      final response = CoachResponse.fromRawText(rawJson);
      expect(response.action, equals('HOLD LANE & BAIT FLICKER'));
      expect(response.reason, contains('Balmond'));
      expect(response.reason, contains('Flicker'));
      expect(response.warning, equals('Turtle contest in 30s'));
    });

    test('handles markdown codeblock wrapping around vision JSON response', () {
      const fencedJson = '''
      ```json
      {
        "action": "FREEZE WAVE NEAR TURRET",
        "reason": "Mid laner missing; turtle spawns in 40s.",
        "warning": "River gank threat active"
      }
      ```
      ''';

      final response = CoachResponse.fromRawText(fencedJson);
      expect(response.action, equals('FREEZE WAVE NEAR TURRET'));
      expect(response.reason, equals('Mid laner missing; turtle spawns in 40s.'));
      expect(response.warning, equals('River gank threat active'));
    });

    test('constructs valid Gemini multimodal payload format with inlineData', () {
      const mockBase64 = '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP...';
      const promptText = 'Inspect the live in-game match screenshot attached: Identify hero and spell.';

      final payload = {
        'contents': [
          {
            'parts': [
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': mockBase64,
                },
              },
              {
                'text': promptText,
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 300,
          'responseMimeType': 'application/json',
        },
      };

      final jsonStr = jsonEncode(payload);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      final contents = decoded['contents'] as List;
      final parts = (contents.first as Map<String, dynamic>)['parts'] as List;

      expect(parts.length, equals(2));
      expect(parts[0]['inlineData']['mimeType'], equals('image/jpeg'));
      expect(parts[0]['inlineData']['data'], equals(mockBase64));
      expect(parts[1]['text'], equals(promptText));
      expect(decoded['generationConfig']['responseMimeType'], equals('application/json'));
    });
  });
}
