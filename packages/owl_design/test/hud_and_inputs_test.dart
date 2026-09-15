// language: Dart, file: hud_and_inputs_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_design/owl_design.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwlTextField tests', () {
    testWidgets('renders label, hint, and accepts text input', (tester) async {
      String entered = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: OwlTextField(
              labelText: 'GEMINI API KEY',
              hintText: 'Enter API Key...',
              onChanged: (val) => entered = val,
            ),
          ),
        ),
      );

      expect(find.text('GEMINI API KEY'), findsOneWidget);
      expect(find.text('Enter API Key...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'AIzaSyDemo123');
      await tester.pump();

      expect(entered, 'AIzaSyDemo123');
      // Clear button should now appear
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(entered, '');
    });

    testWidgets('toggles obscure text for password / API key mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OwlTextField(
              isPassword: true,
              initialValue: 'secret_token_key',
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      TextField textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isTrue);

      // Tap eye toggle
      final eyeButton = find.byIcon(Icons.visibility_outlined);
      expect(eyeButton, findsOneWidget);
      await tester.tap(eyeButton);
      await tester.pump();

      textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isFalse);
    });

    testWidgets('renders error outline and warning message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OwlTextField(
              labelText: 'STATUS',
              errorText: 'Key validation failed',
            ),
          ),
        ),
      );

      expect(find.text('Key validation failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });

  group('OwlTacticalPill tests', () {
    testWidgets('renders objective name and formatted countdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: OwlTacticalPill(
              objectiveName: 'DRAGON',
              countdownSeconds: 42,
              isDraggable: false,
            ),
          ),
        ),
      );

      expect(find.text('DRAGON'), findsOneWidget);
      expect(find.text('00:42'), findsOneWidget);
    });

    testWidgets('taps expand drawer and displays quick actions', (tester) async {
      String selectedAction = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: OwlTacticalPill(
              objectiveName: 'BARON',
              countdownSeconds: 15,
              onQuickAction: (act) => selectedAction = act,
              isDraggable: false,
            ),
          ),
        ),
      );

      // Drawer is collapsed initially
      expect(find.text('TACTICAL TELEMETRY'), findsNothing);

      // Tap pill
      await tester.tap(find.text('BARON'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('TACTICAL TELEMETRY'), findsOneWidget);
      expect(find.text('CONTEST'), findsOneWidget);

      // Tap quick action
      await tester.tap(find.text('CONTEST'));
      await tester.pump();
      expect(selectedAction, 'CONTEST');
    });
  });

  group('OwlActionSheet tests', () {
    testWidgets('renders match pings and fires onPingSelected', (tester) async {
      OwlTacticalPing? picked;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: OwlActionSheet(
              onPingSelected: (ping) => picked = ping,
            ),
          ),
        ),
      );

      expect(find.text('TACTICAL PINGS'), findsOneWidget);
      expect(find.text('MID MISSING'), findsOneWidget);
      expect(find.text('CONTEST OBJECTIVE'), findsOneWidget);
      expect(find.text('LORD / BARON'), findsOneWidget);

      await tester.tap(find.text('MID MISSING'));
      await tester.pump();

      expect(picked, isNotNull);
      expect(picked?.id, 'mid_missing');
    });
  });

}
