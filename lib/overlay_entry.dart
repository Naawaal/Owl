import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owl/features/overlay/overlay.dart';
import 'package:owl/features/overlay/presentation/gameturbo_floating_toolbox.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_storage/owl_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated Flutter entrypoint for the in-game system overlay.
/// Hosts the same [GameturboFloatingToolbox] used on Console — 1:1 UI.
@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const _OverlayToolboxRoot(),
    ),
  );
}

class _OverlayToolboxRoot extends ConsumerStatefulWidget {
  const _OverlayToolboxRoot();

  @override
  ConsumerState<_OverlayToolboxRoot> createState() =>
      _OverlayToolboxRootState();
}

class _OverlayToolboxRootState extends ConsumerState<_OverlayToolboxRoot>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel('com.example.owl/overlay_ui');

  late final AnimationController _enterController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _closing = false;
  Offset _slideBegin = const Offset(-0.12, 0);

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 160),
    );
    final curved = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.94, end: 1).animate(curved);

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'configure':
          final args = call.arguments;
          if (args is Map) {
            OverlaySessionArgs.instance.applyMap(args);
            _applySessionModeHint();
            _syncSlideFromEdge();
          }
          break;
        case 'shown':
          await _reloadPrefs();
          unawaited(ref.read(voiceChangerProvider.notifier).syncFromNative());
          if (mounted && !_enterController.isCompleted) {
            unawaited(_enterController.forward());
          }
          break;
      }
      return null;
    });
    OverlaySessionArgs.instance.addListener(_onArgs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_requestConfig());
      _syncSlideFromEdge();
      unawaited(_enterController.forward());
    });
  }

  void _syncSlideFromEdge() {
    final fromRight = OverlaySessionArgs.instance.edgeOnRight;
    _slideBegin = Offset(fromRight ? 0.12 : -0.12, 0);
    if (mounted) setState(() {});
  }

  Future<void> _requestConfig() async {
    try {
      final args = await _channel.invokeMethod<dynamic>('requestConfig');
      if (args is Map) {
        OverlaySessionArgs.instance.applyMap(args);
        _applySessionModeHint();
        _syncSlideFromEdge();
      }
    } catch (_) {}
  }

  void _applySessionModeHint() {
    final hint = OverlaySessionArgs.instance.isPerformance;
    if (hint == null || !mounted) return;
    ref.read(gameTurboSettingsProvider.notifier).applySessionModeHint(hint);
  }

  Future<void> _reloadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      if (mounted) {
        ref.read(gameTurboSettingsProvider.notifier).reloadFromDisk();
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _onArgs() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    OverlaySessionArgs.instance.removeListener(_onArgs);
    _channel.setMethodCallHandler(null);
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    try {
      await _enterController.reverse();
    } catch (_) {}
    try {
      await _channel.invokeMethod<void>('collapse');
    } catch (_) {}
  }

  /// Vertical alignment in [-1, 1] so panel centers near the edge rail.
  Alignment _panelAlignment(OverlaySessionArgs args, Size size) {
    final x = args.edgeOnRight ? 1.0 : -1.0;
    final screenH = args.screenHeight ?? size.height;
    final anchor = args.anchorY;
    if (anchor == null || screenH <= 0) {
      return Alignment(x, 0);
    }
    // Convert TOP-origin pixels → Alignment y (-1 top, 1 bottom).
    final yFrac = ((anchor / screenH) * 2.0) - 1.0;
    final y = yFrac.clamp(-0.85, 0.85);
    return Alignment(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final args = OverlaySessionArgs.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        backgroundColor: ColorPrimitives.scrimBlack35,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final alignment = _panelAlignment(args, size);
            final slideAnim = Tween<Offset>(
              begin: _slideBegin,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _enterController,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Align(
                  alignment: alignment,
                  child: GestureDetector(
                    onTap: () {},
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: slideAnim,
                        child: ScaleTransition(
                          scale: _scale,
                          alignment: args.edgeOnRight
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GameturboFloatingToolbox(
                            gameTitle: args.gameTitle,
                            targetFps: args.targetFps,
                            matchElapsedSeconds: args.matchElapsedSeconds,
                            onClose: _close,
                            onOpenGpuSettings: () async {
                              try {
                                await _channel
                                    .invokeMethod<void>('openGpuSettings');
                              } catch (_) {}
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
