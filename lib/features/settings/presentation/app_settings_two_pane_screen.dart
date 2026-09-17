// language: Dart, file: app_settings_two_pane_screen.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/ai_coach/data/tts_announcer.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_ai_provider_section.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_alerts_section.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_assistant_section.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_general_section.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_navigation_sidebar.dart';
import 'package:owl/features/settings/presentation/widgets/sections/settings_performance_section.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Two-Pane Global Application & Tactical Settings Screen.
///
/// Implements 1:1 parity with the finalized Owl Tactical Settings prototype:
/// - Top System Bar with dynamic model status, cyan pulse latency badge, and quick reset.
/// - Left Sidebar: Categorized into Active MVP Categories.
/// - Right Pane: Modular glassmorphic settings sections.
class AppSettingsTwoPaneScreen extends ConsumerStatefulWidget {
  const AppSettingsTwoPaneScreen({
    super.key,
    this.initialCategory = AppSettingCategory.general,
  });

  final AppSettingCategory initialCategory;

  @override
  ConsumerState<AppSettingsTwoPaneScreen> createState() =>
      _AppSettingsTwoPaneScreenState();
}

enum AppSettingCategory {
  general('General settings', LucideIcons.settings),
  aiProviders('AI Provider & Models', LucideIcons.cpu),
  assistant('Assistant & Tactical AI', LucideIcons.bot),
  alerts('Voice & Alerts', LucideIcons.volume2),
  performance('Assistant Performance', LucideIcons.gauge);

  const AppSettingCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _AppSettingsTwoPaneScreenState
    extends ConsumerState<AppSettingsTwoPaneScreen> {
  late AppSettingCategory _selectedCategory;

  // Key management state
  final TextEditingController _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _isValidatingKey = false;
  String? _keyTestResult;
  String? _keyValidationError;

  // Simulated Tactical In-App Alert Toast
  bool _showToastAlert = false;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _keyController.addListener(_onKeyChanged);
    ref.read(gameTurboSettingsProvider.notifier).onPersistError = (message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    };
    _loadCurrentApiKey();
  }

  void _onKeyChanged() {
    if (_keyValidationError != null && mounted) {
      setState(() => _keyValidationError = null);
    }
  }

  @override
  void dispose() {
    _keyController.removeListener(_onKeyChanged);
    _keyController.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentApiKey([String? explicitProvider]) async {
    final settings = ref.read(gameTurboSettingsProvider);
    final provider = explicitProvider ?? settings.activeAiProvider;
    final keyManager = ref.read(apiKeyManagerProvider);
    final key = await keyManager.getApiKey(provider);
    if (mounted) {
      setState(() {
        _keyController.text = key ?? '';
        _keyTestResult = null;
        _keyValidationError = null;
      });
    }
    unawaited(
      ref
          .read(gameDiscoveryServiceProvider)
          .setAiCredentials(
            apiKey: (key != null && key.isNotEmpty) ? key : null,
            provider: provider,
            model: settings.activeModel,
          )
          .catchError((_) => false),
    );
  }

  Future<void> _testAndSaveKey() async {
    final settings = ref.read(gameTurboSettingsProvider);
    final keyManager = ref.read(apiKeyManagerProvider);
    final text = _keyController.text.trim();

    final validationErr =
        keyManager.validateKeyFormat(settings.activeAiProvider, text);
    if (validationErr != null) {
      setState(() {
        _keyValidationError = validationErr;
        _keyTestResult = null;
      });
      return;
    }

    setState(() {
      _isValidatingKey = true;
      _keyValidationError = null;
      _keyTestResult = null;
    });

    try {
      final latency = await keyManager.testConnection(
        settings.activeAiProvider,
        text,
        model: settings.activeModel,
      );
      await keyManager.saveApiKey(settings.activeAiProvider, text);
      unawaited(
        ref
            .read(gameDiscoveryServiceProvider)
            .setAiCredentials(
              apiKey: text,
              provider: settings.activeAiProvider,
              model: settings.activeModel,
            )
            .catchError((_) => false),
      );
      if (mounted) {
        setState(() {
          _isValidatingKey = false;
          _keyTestResult = 'Active • ${latency}ms latency';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'API Key validated and saved securely (${latency}ms round-trip).',
            ),
            backgroundColor: ColorSemantics.turboBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingKey = false;
          _keyValidationError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _triggerTestCallout() {
    final settings = ref.read(gameTurboSettingsProvider);

    if (settings.hapticsEnabled) {
      HapticHelper.heavyImpact();
    }

    if (settings.voiceAlertsEnabled) {
      final audioFocus = !settings.avoidInterruptingGameAudio;
      ref.read(ttsAnnouncerProvider).speak(
            'Tactical alert: Enemy jungler missing from bottom river!',
            focus: audioFocus,
          );
    }

    _toastTimer?.cancel();
    setState(() => _showToastAlert = true);
    _toastTimer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted) setState(() => _showToastAlert = false);
    });

    final colors = ColorTokens.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.alertTriangle,
                size: 16, color: colors.tacticalAmber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚠️ Tactical Alert: Enemy Jungler missing from Bot River!',
                style: TypographyTokens.bodySmallOf(context).copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.isLight
            ? colors.surfaceElevated
            : ColorPrimitives.toastScrim,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);

    final colors = ColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.consoleBase,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: OwlAtmosphericBackground()),
          SafeArea(
            left: false,
            right: false,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontFamily: TypographyTokens.uiFontFamily,
              ),
              child: Column(
                children: [
                  const SettingsTopBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SettingsCategorySidebar(
                              selectedCategory: _selectedCategory,
                              onSelectCategory: (cat) =>
                                  setState(() => _selectedCategory = cat),
                            ),
                            Expanded(
                              child: _buildContentPane(settings, notifier),
                            ),
                          ],
                        ),
                        if (_showToastAlert)
                          Positioned(
                            top: 14,
                            right: 24,
                            child: _buildTacticalToastBanner(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPane(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return switch (_selectedCategory) {
      AppSettingCategory.general => SettingsGeneralSection(
          settings: settings,
          notifier: notifier,
          onResetDefaults: () {
            HapticHelper.mediumImpact();
            notifier.resetToDefaults();
            _loadCurrentApiKey();
          },
        ),
      AppSettingCategory.aiProviders => SettingsAiProviderSection(
          settings: settings,
          notifier: notifier,
          keyController: _keyController,
          obscureKey: _obscureKey,
          onToggleObscureKey: () =>
              setState(() => _obscureKey = !_obscureKey),
          keyValidationError: _keyValidationError,
          keyTestResult: _keyTestResult,
          isValidatingKey: _isValidatingKey,
          onTestAndSaveKey: _testAndSaveKey,
          onSelectProvider: (p) {
            notifier.setActiveAiProvider(p);
            _loadCurrentApiKey(p);
          },
        ),
      AppSettingCategory.assistant => SettingsAssistantSection(
          settings: settings,
          notifier: notifier,
        ),
      AppSettingCategory.alerts => SettingsAlertsSection(
          settings: settings,
          notifier: notifier,
          onTriggerTestCallout: _triggerTestCallout,
        ),
      AppSettingCategory.performance => SettingsPerformanceSection(
          settings: settings,
          notifier: notifier,
        ),
    };
  }

  Widget _buildTacticalToastBanner() {
    final colors = ColorTokens.of(context);
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.isLight
            ? colors.surfaceCard.withValues(alpha: 0.9)
            : colors.surfaceElevated.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.turboBlue.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle,
              size: 18, color: colors.tacticalAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⚠️ Tactical Voice Callout',
                  style: TypographyTokens.dialogActionOf(context).copyWith(
                    fontSize: 11,
                    color: colors.tacticalAmber,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"Enemy Mid is rotating Bot river! Fall back to turret."',
                  style: TypographyTokens.bodySmallOf(context).copyWith(
                    fontSize: 10.5,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
