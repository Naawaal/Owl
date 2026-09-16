// language: Dart, file: gameturbo_screens_test.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl/features/game_profiles/presentation/game_space_console_screen.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/overlay/presentation/tactical_battlefield_hud.dart';
import 'package:owl/features/settings/presentation/app_settings_two_pane_screen.dart';
import 'package:owl/features/settings/presentation/gpu_settings_two_pane_screen.dart';

import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Xiaomi HyperOS Game Turbo 2026 Screens Test Suite', () {
    testWidgets('GameSpaceConsoleScreen renders all flagship OEM elements', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: GameSpaceConsoleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top Status Bar — finalized reference values with native fallback
      expect(find.text('71%'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);

      // Left Sidebar (Dynamic Gamebox)
      expect(find.textContaining('Gamebox'), findsOneWidget);

      // Center Hero Showcase — finalized cinematic spec
      expect(find.text('5V5 ACTION GAMEPLAY'), findsOneWidget);
      expect(find.text('SKILL LEADS TO VICTORY'), findsOneWidget);
      expect(find.text('TRIPLE KILL'), findsOneWidget);

      // Right Action Wing — bolt icon + Play + auto-turbo subtext
      expect(find.text('Play'), findsOneWidget);
      expect(find.textContaining('Game Turbo can turn on automatically'),
          findsOneWidget);

      // Bottom GPU Tab
      expect(find.text('GPU settings'), findsOneWidget);
    });

    testWidgets('AppSettingsTwoPaneScreen renders categories and switches', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: AppSettingsTwoPaneScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Game Turbo Settings'), findsOneWidget);

      // Categories
      expect(find.text('General settings'), findsOneWidget);
      expect(find.text('Performance mode'), findsOneWidget);
      expect(find.text('Game DND'), findsOneWidget);
      expect(find.text('Guardian AI Core'), findsOneWidget);

      // Default General Settings content
      expect(find.text('Game Turbo Master Engine'), findsOneWidget);
      expect(find.text('In-Game Floating Shortcuts'), findsOneWidget);
      expect(find.text('Shortcut Edge Position'), findsOneWidget);

      // Switch to Performance mode category
      await tester.tap(find.text('Performance mode'));
      await tester.pumpAndSettle();

      expect(find.text('Performance Optimization'), findsOneWidget);
      expect(find.text('Wi-Fi Speed Boost'), findsOneWidget);
      expect(find.text('Aggressive Memory Cleanup'), findsOneWidget);
      expect(find.text('Spatial Audio Enhancement'), findsOneWidget);

      // Switch to Guardian AI Core category
      await tester.tap(find.text('Guardian AI Core'));
      await tester.pumpAndSettle();

      expect(find.text('Guardian Tactical Engine'), findsOneWidget);
      expect(find.text('AI Vision Inference Backend'), findsOneWidget);
      expect(find.text('Audio Tactical Callouts'), findsOneWidget);
      expect(find.text('Enemy Rotation & Missing Radar'), findsOneWidget);
    });

    testWidgets('GpuSettingsTwoPaneScreen renders segmented chips and resets default', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: GpuSettingsTwoPaneScreen(gameTitle: 'Mobile Legends: Bang Bang'),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('GPU settings — Mobile Legends: Bang Bang'), findsOneWidget);
      expect(find.text('Reset Default'), findsOneWidget);

      // Graphic Quality Category
      expect(find.text('Target Frame Rate Cap'), findsOneWidget);
      expect(find.text('Render Resolution Scale'), findsOneWidget);
      expect(find.text('Multi-Sample Anti-Aliasing (MSAA)'), findsOneWidget);
      expect(find.text('Anisotropic Texture Filtering'), findsOneWidget);

      // Switch to Touch Controls
      await tester.tap(find.text('Touch Controls'));
      await tester.pumpAndSettle();

      expect(find.text('Touch Response Sampling Rate'), findsOneWidget);
      expect(find.text('Aiming & Skill Shot Precision'), findsOneWidget);
      expect(find.text('Edge Mistouch Rejection Area'), findsOneWidget);

      // Switch to Tactical AI Modules
      await tester.tap(find.text('Tactical AI Modules'));
      await tester.pumpAndSettle();

      expect(find.text('Minimap Threat Radar'), findsOneWidget);
      expect(find.text('Turtle & Lord Spawn Countdown Rings'), findsOneWidget);
      expect(find.text('Retribution / Smite Execution Threshold'), findsOneWidget);
    });

    testWidgets('TacticalBattlefieldHud edge handle expands 2026 Game Turbo toolbox', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(
            home: TacticalBattlefieldHud(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Top Status Bar & Edge Handle (matching Game Space Console)
      expect(find.text('Game Space'), findsOneWidget);
      expect(find.text('TURBO 120 FPS'), findsOneWidget);

      // Tap edge handle to open compact toolbox
      await tester.tap(find.text('TURBO 120 FPS'));
      await tester.pumpAndSettle();

      // Verify compact toolbox is open without bloat
      expect(find.byType(GameturboFloatingToolbox), findsOneWidget);
      expect(find.text('Gaming tools'), findsOneWidget);
      expect(find.text('Games'), findsNothing); // Confirmed: Games tab removed!

      // Circular Tachometer FPS Gauge & Horizontal Telemetry Meters
      expect(find.text('120'), findsOneWidget);
      expect(find.text('FPS'), findsWidgets);
      expect(find.text('帧率'), findsNothing); // Confirmed: Chinese words removed!
      expect(find.text('CPU'), findsWidgets);
      expect(find.text('GPU'), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);

      // Essential 4 Quick Tools (DND, Wi-Fi, AI, Voice)
      expect(find.text('DND'), findsOneWidget);
      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);

      // Verified removed items (Boost, Mistouch, GPU Settings, Cast, Comments, More tools)
      expect(find.text('Boost'), findsNothing);
      expect(find.text('Mistouch'), findsNothing);
      expect(find.text('GPU Settings'), findsNothing);
      expect(find.text('Cast'), findsNothing);
      expect(find.text('Comments'), findsNothing);
      expect(find.text('More tools'), findsNothing);

      // Tap close button (Lucide icon)
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();

      // Toolbox closed, edge handle restored
      expect(find.byType(GameturboFloatingToolbox), findsNothing);
      expect(find.text('TURBO 120 FPS'), findsOneWidget);
    });
  });
}
